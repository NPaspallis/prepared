import 'dart:convert';

import 'package:app/model/badge_entry.dart';
import 'package:app/model/story_progress.dart';
import 'package:app/schema/component/badge_component.dart';
import 'package:app/secrets.dart';
import 'package:app/util/device_utils.dart';
import 'package:app/util/pref_utils.dart';
import 'package:app/util/ui_utils.dart';
import 'package:app/ui/widgets/buttons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// A component that allows the user to enter their details to be awarded a
/// badge.
class BadgeComponentView extends StatefulWidget {

  final String storyId;
  final BadgeComponent component;

  const BadgeComponentView(this.storyId, this.component, {super.key});

  @override
  State<BadgeComponentView> createState() => _BadgeComponentViewState();
}

const linkedInOrganizationId = '88654255'; // PREPARED project's organization id on LinkedIn
const firebaseCollectionBadges = 'BadgeEntry';

enum ClaimStatus { unclaimed, claiming, error, issued }

const firebaseSettings = '_Settings';
const firebaseSettingsDocumentBadgeApi = 'BadgeApi';
const keyPrefsUsername = 'keyPrefsUsername';
const keyPrefsPassword = 'keyPrefsPassword';

class _BadgeComponentViewState extends State<BadgeComponentView> {

  ClaimStatus _claimStatus = ClaimStatus.claiming;

  String _name = "";
  String _email = "";
  String _date = "";
  String _errorDescription = "";
  String _openBadgeId = "";

  late String _username;
  late String _password;

  @override
  void initState() {
    super.initState();

    // check credentials, first in preferences, next on Firebase
    checkCredentials();

    // check if a badge is already issued for this deviceId/badgeClassId
    checkBadgeOnFirebase();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkCredentials() async {
    // first check preferences
    var prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(keyPrefsUsername) ?? '';
    _password = prefs.getString(keyPrefsPassword) ?? '';

    // next, if not set yet, fetch latest values from Firebase
    if(_username.isEmpty || _password.isEmpty) {
      _username = Secrets.getSecret('badgr-username');
      _password = Secrets.getSecret('badgr-password');
      // save in prefs for future use
      prefs.setString(keyPrefsUsername, _username);
      prefs.setString(keyPrefsPassword, _password);
    }
  }

  ///Checks whether this user has already gotten this badge
  void checkBadgeOnFirebase() async {
    //Try to find if there are existing entries for this poll on Firestore:
    String deviceID = (await DeviceUtils.getInstallationID())!;
    String badgeEntryID = PreferenceUtils.constructBadgeClassDeviceID(widget.component.badgeClassId, deviceID);
    var documentSnapshot = await FirebaseFirestore.instance.collection(firebaseCollectionBadges).doc(badgeEntryID).get();

    if (documentSnapshot.exists) {
      var badgeEntryData = documentSnapshot.data()!;
      // debugPrint('documentSnapshot: $badgeEntryData');
      setState(() {
        _name = badgeEntryData['name'];
        _email = badgeEntryData['email'];
        _date = badgeEntryData['date'];
        _openBadgeId = badgeEntryData['badgeId'];
        _claimStatus = ClaimStatus.issued;

        // completed - once badge is verified (exists)
        Provider.of<StoryProgress>(context, listen: false).setCompleted(widget.storyId, widget.component.getID(), true);
      });
    }
    else {
      setState(() {
        _claimStatus = ClaimStatus.unclaimed;
      });
    }
  }

  ///Creates a new badge entry on Firestore, given its
  void createBadgeEntry(String badgeId, String name, String email, String date) async {
    String deviceID = (await DeviceUtils.getInstallationID())!;
    final BadgeEntry badgeEntry = BadgeEntry(badgeId, name, email, date);
    final String badgeEntryID = PreferenceUtils.constructBadgeClassDeviceID(widget.component.badgeClassId, deviceID);
    FirebaseFirestore.instance.collection(firebaseCollectionBadges).doc(badgeEntryID).set(badgeEntry.toJson())
        .then((value) {
          // debugPrint('Entry created on Firebase: $badgeEntry');
          setState(() {
            _claimStatus = ClaimStatus.issued;

            // completed - once badge is created
            Provider.of<StoryProgress>(context, listen: false).setCompleted(widget.storyId, widget.component.getID(), true);
          });
        })
        .catchError((error) {
          UIUtils.showErrorToast("Error while submitting answer, please try again.");
          setState(() {
            _errorDescription = 'Error while writing to the cloud ($error)';
            _claimStatus = ClaimStatus.error;
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    Image imageWidget;

    if (widget.component.badgeImageUrl.startsWith("http")) {
      imageWidget = Image(
        image: CachedNetworkImageProvider(widget.component.badgeImageUrl),
        fit: BoxFit.fitWidth,
      );
    }
    else {
      imageWidget =
          Image.asset(widget.component.badgeImageUrl, fit: BoxFit.fitWidth);
    }

    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              children: [

                FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    widthFactor: 0.5,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          // Image border
                          child: AspectRatio(aspectRatio: 1, child: imageWidget)
                      ),
                    )
                ),

                Container(height: 20),
                Text(
                    widget.component.badgeName,
                    // style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20))
                    style: const TextStyle(fontFeatures:[FontFeature.enable('smcp')], fontWeight: FontWeight.w900)
                ),

                Container(height: 20),
                const Divider(height: 1, color: Colors.grey),

                ...selectUI() // load all selected widgets
              ]
          )
        )
    );
  }

  List<Widget> selectUI() {
    switch(_claimStatus) {
      case ClaimStatus.unclaimed:
        return getClaimBadgeUI();
      case ClaimStatus.claiming:
        return [
          Container(height: 20),
          const Text("Fetching badge ..."),
          Container(height: 20),
          const SizedBox(height: 100.0, width: 100.0, child: CircularProgressIndicator(strokeWidth: 10))
        ];
      case ClaimStatus.issued:
        return getRegisteredBadgeUI();
      case ClaimStatus.error:
        return getErrorUI();
      default:
        return [
          Text('Error: unknown claim status: $_claimStatus')
        ];
    }
  }

  List<Widget> getClaimBadgeUI() {
    return [
      Container(height: 20),
      SizedBox(
          width: double.infinity,
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle
                  .of(context)
                  .style,
              children: const <TextSpan>[
                TextSpan(text: 'Congratulations! ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: 'You can claim a badge.'),
              ],
            ),
          )
      ),

      Container(height: 20),
      const Text('To make it official, please provide your name to be printed on the badge, and your email so you can receive a digital copy.'),

      Container(height: 20),
      const SizedBox(
        width: double.infinity,
        child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          initialValue: _name,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          validator: validateName,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter name to be printed on badge',
          ),
          onChanged: (value) => setState(() => _nameOK = validateName(value) == null),
        ),
      ),

      Container(height: 20),
      const SizedBox(
        width: double.infinity,
        child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          initialValue: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: validateEmail,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Email for sending badge',
          ),
          onChanged: (value) => setState(() => _emailOK = validateEmail(value) == null),
        ),
      ),

      Container(height: 20),
      ElevatedButton(
          onPressed: _nameOK && _emailOK ? _claimBadge : null,
          child: const Text("CLAIM BADGE")
      )
    ];
  }

  List<Widget> getRegisteredBadgeUI() {
    return [
      Container(height: 20),
      const Text('Your badge is created!'),

      Container(height: 20),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 10,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Table(
              border: const TableBorder(horizontalInside: BorderSide(width: 1, style: BorderStyle.solid)),
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
                2: IntrinsicColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  decoration: const BoxDecoration(color: Colors.white),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(_name, overflow: TextOverflow.ellipsis),
                    const SizedBox(width: 10)
                  ],
                ),
                TableRow(
                  decoration: const BoxDecoration(color: Colors.white),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(_email, overflow: TextOverflow.ellipsis),
                    const SizedBox(width: 10)
                  ],
                ),
                TableRow(
                  decoration: const BoxDecoration(color: Colors.white),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(_date, overflow: TextOverflow.ellipsis),
                    const SizedBox(width: 10)
                  ],
                ),
                TableRow(
                  decoration: const BoxDecoration(color: Colors.white),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text('Badge ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(_openBadgeId.substring(_openBadgeId.lastIndexOf("/") + 1), overflow: TextOverflow.ellipsis),
                    const SizedBox(width: 10)
                  ],
                ),
              ],
            )
        ),
      ),

      const SizedBox(height: 20),
      createButtonWithIcon('View online', const Icon(FontAwesomeIcons.solidIdBadge, size: 16), _openLinkToOpenBadgeId, key: const Key('button-view-badge')),
      const SizedBox(height: 20),
      createButtonWithIcon('Add to LinkedIn', const Icon(FontAwesomeIcons.linkedin, size: 16), _showLinkedInDialog, key: const Key('button-add-to-linkedin')),
    ];
  }

  void _openLinkToOpenBadgeId() async {
    // open in web browser
    final Uri url = Uri.parse(_openBadgeId);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  final addToLinkedInUrl = 'https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME&name=%%badgeName%%&issueYear=%%issueYear%%&issueMonth=%%issueMonth%%&certUrl=%%certUrl%%&organizationId=%%organizationId%%&certId=%%certId%%';

  Uri _getLinkedInUrl() {
    if(_date.length < 10) {
      setState(() => _date = DateFormat('yyyy-MM-dd').format(DateTime.now()));
    }
    String year = _date.substring(0, 4);
    String month = _date.substring(5, 7);
    String badgeId = _openBadgeId.substring(_openBadgeId.lastIndexOf("/") + 1); // extract id from url

    // form the url
    final String inflatedUrl = addToLinkedInUrl
        .replaceFirst("%%badgeName%%", widget.component.badgeName)
        .replaceFirst("%%organizationId%%", linkedInOrganizationId)
        .replaceFirst("%%issueYear%%", year)
        .replaceFirst("%%issueMonth%%", month)
        .replaceFirst("%%certId%%", badgeId)
        .replaceFirst("%%certUrl%%", Uri.encodeComponent(_openBadgeId)); // this is actually the badgr url
    return Uri.parse(inflatedUrl);
  }

  void _copyLinkedInUrlToClipboard() async {
    final Uri url = _getLinkedInUrl();
    if (kDebugMode) {
      print('Add to LinkedIn using url: $url');
    }
    await Clipboard.setData(ClipboardData(text: '$url'));
    UIUtils.showNeutralToast('Url copied to clipboard', gravity: ToastGravity.BOTTOM);
  }

  void _addToLinkedIn() async {
    final Uri url = _getLinkedInUrl();
    if (kDebugMode) {
      print('Add to LinkedIn using url: $url');
    }
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showLinkedInDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row( children: [
          Text('Add to LinkedIn'),
          SizedBox(width: 10),
          Icon(FontAwesomeIcons.linkedin)
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Adding the badge to your LinkedIn profile is a great way to highlight your achievement.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Text('If the LinkedIn App is installed on your mobile device, simply click the "Add to LinkedIn" button to get a prefilled form.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Text('Otherwise use the "Copy Url" to save the Url in the clipboard and then open it on your desktop\'s or laptop\'s web browser.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          createButtonWithoutIcon('Add to LinkedIn', _addToLinkedIn, key: const Key('button-dialog-add-to-linkedin')),
          createButtonWithIcon('Copy Url', const Icon(Icons.copy, size: 16), _copyLinkedInUrlToClipboard, key: const Key('button-dialog-copy-to-clipboard')),
        ],
        elevation: 24,
      )
    );
  }

  List<Widget> getErrorUI() {
    return [
      Container(height: 20),
      Text('System Error: $_errorDescription', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),

      Container(height: 20),
      ElevatedButton(
        onPressed: tryAgain,
        child: const Text('TRY AGAIN')
      )
    ];
  }

  void tryAgain() {
    setState(() {
      _errorDescription = "";
      _claimStatus = ClaimStatus.unclaimed;
    });
  }

  bool _nameOK = false;
  bool _emailOK = false;

  void _claimBadge() async {
    // debugPrint('name: $_name, email: $_email, date: $_date');
    _date = DateTime.now().toIso8601String().substring(0, 10);

    setState(() => _claimStatus = ClaimStatus.claiming);

    // 1. check on Firebase that the given device_id / email / badge_class_id have not been granted this badge already
    // checked already onInit

    // 2. get access token
    http.Response accessTokenResponse = await getAccessToken(_username, _password);
    var responseData = jsonDecode(accessTokenResponse.body);
    if(accessTokenResponse.statusCode != 200) {
      // debugPrint('GET ACCESS TOKEN: responseData: $responseData');
      setState(() {
        _errorDescription = 'status code ${accessTokenResponse.statusCode}';
        _claimStatus = ClaimStatus.error;
      });
      return; // end function
    }

    String accessToken = responseData['access_token'];
    // debugPrint('accessToken: $accessToken');

    // 3. proceed to issue the badge
    http.Response issueBadgeResponse = await issueBadge(accessToken, widget.component.badgeName, widget.component.issuerId, widget.component.badgeClassId, _name, _email);
    var issueBadgeResponseData = jsonDecode(issueBadgeResponse.body);
    // debugPrint('ISSUE BADGE: issueBadgeResponseData: $issueBadgeResponseData');
    if(issueBadgeResponse.statusCode < 200 || issueBadgeResponse.statusCode >= 300) { // OK range is 2xx
      setState(() {
        _errorDescription = 'status code ${issueBadgeResponse.statusCode} - ${issueBadgeResponseData['error']}';
        _claimStatus = ClaimStatus.error;
      });
      return; // end function
    }

    _openBadgeId = issueBadgeResponseData['result'][0]['openBadgeId'];
    // debugPrint('openBadgeId: $_openBadgeId');

    createBadgeEntry(_openBadgeId, _name, _email, _date);
  }

  Future<http.Response> getAccessToken(final String username, final String password) async {
    const accessTokenUrl = 'https://api.badgr.io/o/token/';

    return http.post(
        Uri.parse(accessTokenUrl),
        headers: <String, String> {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
            "username": username,
            "password": password
        }
    );
  }

  Future<http.Response> issueBadge(final String accessToken, final String badgeName, final String issuerId, final String badgeClassId, final String name, final String email) async {
    final badgeIssueUrl = 'https://api.badgr.io/v2/badgeclasses/$badgeClassId/assertions';

    var body = jsonEncode({
      'recipient': {
        'identity': email,
        'hashed': false,
        'type': 'email',
        'plaintextIdentity': name,
        'name': name
      },
      'issuer': issuerId,
      'narrative': 'Awarded to **$name** for completing: $badgeName.',
      'extensions:recipientProfile': {
        'name': name,
        '@context': "https://openbadgespec.org/extensions/recipientProfile/context.json",
        'type': [
          'Extension',
          'extensions:RecipientProfile'
        ]
      }
    });


    return http.post(
        Uri.parse(badgeIssueUrl),
        headers: <String, String> {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json"
        },
        body: body
    );
  }

  String? validateName(String? name) {
    _name = name ?? "";
    bool nameValid = name != null && name.isNotEmpty;
    return !nameValid ? 'Enter a non empty name' : null;
  }

  String? validateEmail(String? email) {
    _email = email ?? "";
    bool emailValid = email != null && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email);
    return !emailValid ? 'Enter a valid email address' : null;
  }
}