import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/story_progress.dart';
import '../../schema/bucket/bucket.dart';
import '../../schema/bucket/bucket_item.dart';

import '../../schema/component/bucket_component.dart';
import '../../util/pref_utils.dart';
import '../styles/style.dart';

///A component that allows the user to view a list of items and categorize them into buckets.
class BucketComponentView extends StatefulWidget {

  final String storyId;
  final BucketComponent component;

  const BucketComponentView(this.storyId, this.component, {super.key});

  @override
  State<BucketComponentView> createState() => _BucketComponentViewState();
}

bool _submitted = false;

class _BucketComponentViewState extends State<BucketComponentView> {

  late List<BucketItem> _bucketItems; // the items to be sorted
  late List<BucketRuntime> _bucketRuntimes; // defines the placement of each item in a specific bucket

  @override
  void initState() {
    super.initState();

    setState(() {
      // load from JSON
      _bucketItems = widget.component.items;
      _bucketItems.shuffle(); // make sure their order is random
      _bucketRuntimes = widget.component.buckets.map((Bucket bucket) => BucketRuntime(label: bucket.label, id: bucket.id)).toList();
    });

    // restore state to init the bucketRuntimes (i.e. runtime versions of the buckets which can contain some elements)
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        for (var bucketRuntime in _bucketRuntimes) {
          final List<String> initialBucketContents = prefs.getStringList(_getBucketContentsKey(bucketRuntime.id)) ?? [];
          for(var bucketItemId in initialBucketContents) {
            var bucketItem = _getBucketItemForId(int.parse(bucketItemId));
            _bucketItems.remove(bucketItem); // remove the item from the default list...
            bucketRuntime.bucketItems.add(bucketItem); // ... and add it to the selected bucket
          }
        }

        // load from prefs
        _submitted = prefs.getBool(_getBucketSubmittedKey()) ?? false;
      });
    });

  }

  BucketItem _getBucketItemForId(int id) {
    return widget.component.items.firstWhere((bi) => bi.id == id);
  }

  final GlobalKey _draggableKey = GlobalKey();

  void _bucketItemDroppedOnBucket({
    required BucketItem bucketItem,
    required BucketRuntime bucketRuntime,
  }) {
    setState(() {
      _bucketItems.remove(bucketItem);
      bucketRuntime.bucketItems.add(bucketItem);
      // update prefs
      final List<String> itemIds = bucketRuntime.bucketItems.map((BucketItem bucketItem) => "${bucketItem.id}").toList();
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(_getBucketContentsKey(bucketRuntime.id), itemIds);
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.component.title, style: Theme.of(context).textTheme.titleMedium),
                const Gap(10),
                Text(widget.component.description, style: Theme.of(context).textTheme.bodySmall),
                const Gap(10),
                _buildBucketItemsList(),
                const Gap(10),
                const Divider(),
                ..._buildBucketsArea(),
                Visibility(
                    visible: _bucketItems.isEmpty && !_submitted,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              backgroundColor: Colors.lime.shade50,
                              foregroundColor: Colors.green.shade800,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              elevation: 3
                          ),
                          onPressed: _submitted ? null : _submit,
                          child: Row(
                            children: [
                              const Spacer(),
                              Text("Submit".toUpperCase(), style: const TextStyle(fontSize: normalTextSmall),),
                              const Spacer(),
                              const Icon(Icons.check),
                            ],
                          ),
                        )
                    )
                ),
                Visibility(
                  visible: _submitted,
                  child: Padding(
                    padding: standardPadding,
                    child: Row(
                      children: [

                        _getAccuracy() * 100 >= 60 ?
                        const Icon(Icons.check, color: Colors.green,) :
                        const Icon(Icons.close, color: Colors.red,),

                        const Gap(10),
                        Text('Accuracy is ${(_getAccuracy() * 100).toStringAsFixed(1)}%'),
                      ],
                    )
                  )
                ),
                Visibility(
                  visible: _submitted,
                  child: Card(
                      color: Colors.yellow[100],
                      child: Padding(
                        padding: standardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Feedback:", style: TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 15, width: double.infinity),
                            Text(widget.component.feedback),
                          ],
                        ),
                      )
                  ),
                ),
              ],
            ),
          )
      )
    );
  }

  double _getAccuracy() {
    int correct = 0;
    int population = 0;
    for(BucketRuntime bucketRuntime in _bucketRuntimes) {
      List<BucketItem> bucketItems = bucketRuntime.bucketItems;
      for (BucketItem bucketItem in bucketItems) {
        correct += bucketItem.correctBucketID == bucketRuntime.id ? 1 : 0;
        population++;
      }
    }
    return correct / population;
  }

  String _getBucketContentsKey(int bucketId) {
    return '${PreferenceUtils.keyCurrentBucketIndex}-${widget.storyId}-${widget.component.id}-$bucketId';
  }

  String _getBucketSubmittedKey() {
    return '${PreferenceUtils.keyCurrentBucketIndex}-${widget.storyId}-${widget.component.id}-submitted';
  }

  void _submit() {
    setState(() {
      // store in prefs
      _submitted = true;
      SharedPreferences.getInstance().then((prefs) {
          prefs.setBool(_getBucketSubmittedKey(), true);
      });
      Provider.of<StoryProgress>(context, listen: false).setCompleted(widget.storyId, widget.component.getID(), true);
    });

  }

  Widget _buildBucketItemsList() {
    return Wrap(
      spacing: 4,
      children: _bucketItems.map((BucketItem bucketItem) => _buildBucketItemDraggableView(bucketItem: bucketItem)).toList(),
    );
  }

  Widget _buildBucketItemDraggableView({
    required BucketItem bucketItem,
  }) {
    return LongPressDraggable<BucketItem>(
      data: bucketItem,
      delay: const Duration(milliseconds: 300),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: DraggingListItem(
        dragKey: _draggableKey,
        bucketItem: bucketItem,
      ),
      child: BucketListItem(bucketItem: bucketItem),
    );
  }

  List<Widget> _buildBucketsArea() {
    return _bucketRuntimes.map(_buildBucketWithDropZone).toList();
  }

  Widget _buildBucketWithDropZone(BucketRuntime bucketRuntime) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DragTarget<BucketItem>(
          builder: (context, candidateItems, rejectedItems) {
            return BucketView(
              bucketRuntime: bucketRuntime,
              onDeleted: (BucketItem bucketItem) {
                SharedPreferences.getInstance().then((prefs) {
                  setState(() {
                    bucketRuntime.bucketItems.remove(bucketItem);
                    _bucketItems.add(bucketItem);
                    final List<String> itemIds = bucketRuntime.bucketItems.map((BucketItem bucketItem) => "${bucketItem.id}").toList();
                    prefs.setStringList(_getBucketContentsKey(bucketRuntime.id), itemIds);
                  });
                });
              },
              hasItems: bucketRuntime.bucketItems.isNotEmpty,
              highlighted: candidateItems.isNotEmpty,
            );
          },
          onAccept: (bucketItem) {
            _bucketItemDroppedOnBucket(
              bucketItem: bucketItem,
              bucketRuntime: bucketRuntime,
            );
          },
        ),
      ),
    );
  }
}

class BucketView extends StatelessWidget {
  const BucketView({
    super.key,
    required this.bucketRuntime,
    required this.onDeleted,
    this.highlighted = false,
    this.hasItems = false,
  });

  final BucketRuntime bucketRuntime;
  final Function onDeleted;
  final bool highlighted;
  final bool hasItems;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: highlighted ? 8 : 4,
      color: highlighted ? Colors.yellow : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bucketRuntime.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Wrap(
                children: bucketRuntime.bucketItems.map((BucketItem bucketItem) =>
                    _getChipInBucket(context, bucketItem)
                ).toList(),
              ),
              Visibility(
                visible: !hasItems,
                child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add_box_outlined, size: 24, color: Colors.grey,))
              ),
              Visibility(
                visible: !hasItems,
                child: Text("Empty. Drag items here.", style: Theme.of(context).textTheme.labelMedium),
              )
            ],
          ),
      )
    );
  }

  Widget _getChipInBucket(BuildContext buildContext, BucketItem bucketItem) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 6.0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.grey[100],
      // clipBehavior: Clip.none,
      child: Stack(
        alignment: AlignmentDirectional.centerEnd,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 28, 4),
              child: Text(
                bucketItem.label,
                overflow: TextOverflow.visible,
                softWrap: true,
                maxLines: 4,
                style: Theme.of(buildContext).textTheme.labelMedium,
              ),
            ),
            _submitted ?
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: _getIconForResult(bucketRuntime.id, bucketItem)
                ) :
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                  ),
                  onPressed: () => onDeleted(bucketItem),
                ),
          ],
        )
    );
  }

  Icon _getIconForResult(int bucketId, BucketItem bucketItem) {
    return bucketItem.correctBucketID == bucketId ?
      const Icon(Icons.check, color: Colors.green, size: 16) :
      const Icon(Icons.question_mark_outlined, color: Colors.red, size: 16);
  }
}

class BucketListItem extends StatelessWidget {
  const BucketListItem({
    super.key,
    required this.bucketItem,
    this.isDepressed = false,
  });

  final BucketItem bucketItem;
  final bool isDepressed;

  @override
  Widget build(BuildContext context) {
    return _getChip(context, bucketItem);
  }
}

class DraggingListItem extends StatelessWidget {
  const DraggingListItem({
    super.key,
    required this.dragKey,
    required this.bucketItem
  });

  final GlobalKey dragKey;
  final BucketItem bucketItem;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: Material(
          key: dragKey,
          child: _getChip(context, bucketItem)
      )
    );
  }
}

/// Abstracts a bucket in runtime, with its contained items
class BucketRuntime {
  BucketRuntime({
    required this.label,
    required this.id,
    List<BucketItem>? bucketItems,
  }) : bucketItems = bucketItems ?? [];

  final String label;
  final int id;
  final List<BucketItem> bucketItems;
}

Widget _getChip(BuildContext buildContext, BucketItem bucketItem) {
  return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 6.0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.grey[100],
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: Text(
              bucketItem.label,
              overflow: TextOverflow.visible,
              softWrap: true,
              maxLines: 3,
              style: Theme.of(buildContext).textTheme.labelLarge,
            ),
          ),
          const Icon(Icons.drag_indicator_rounded, size: 16),
        ],
      )
  );
}