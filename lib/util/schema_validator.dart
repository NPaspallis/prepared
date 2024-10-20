import 'dart:convert';
import 'package:app/util/file_utils.dart';
import 'package:app/util/validation_results.dart' as val_res;
import 'package:json_schema/json_schema.dart';

///A utility class that helps validate story JSON files based on a schema.
class SchemaValidator {

  static JsonSchema? jsonValidator;

  ///Validates a JSON object given a certain JSON Schema:
  static Future<val_res.ValidationResults> validateJsonObject(jsonObject, JsonSchema jsonSchema) async {
    var validate = jsonSchema.validate(jsonObject);
    return val_res.ValidationResults(validate.errors, validate.warnings);
  }

  ///Validates a story.
  static Future<val_res.ValidationResults> validateStory(jsonObject) async {
    var jsonSchema = await loadSchemaValidator();
    return validateJsonObject(jsonObject,  jsonSchema);
  }

  ///Creates or retrieves the JSON validator for Story objects:
  static Future<JsonSchema> loadSchemaValidator() async {

    //Only load from assets once:
    if (jsonValidator != null) {
      return jsonValidator!;
    }

    //Defines a list of schemas to be loaded:
    const schemaMainURL = "http://prepared-project.eu/";
    final List<String> referencedSchemas = [
      "bucket",
      "bucket_item",
      "bucket_component",
      "component_choice",
      "metadata_schema",
      "chat_component",
      "discussion_component",
      "html_component",
      "poll_component",
      "multipoll_component",
      "mcq_component",
      "multimcq_component",
      "video_component",
      "branch_component",
      "chat_message",
      "discussion_message",
      "participant",
      "poll_option",
      "mcq_option",
      "audio_component",
      "badge_component",
      "exam_component",
      "exam_question",
      "exam_answer",
    ];

    //Objects to be stored after loading the schemas:
    final List referencedSchemaObjects = [];

    //Load all schemas from the assets and store in referencedSchemaObjects:
    for (String schemaFile in referencedSchemas) {
      String text =
          await FileUtils.loadTextFile("assets/schema/$schemaFile.json");
      var schemaObject = jsonDecode(text);
      referencedSchemaObjects.add(schemaObject);
    }

    //Create a ref provider used to validate the schema out of the referenced schemas:
    final RefProvider refProvider = RefProvider.sync((String ref) {
      final Map references = {};

      for (int i = 0; i < referencedSchemaObjects.length; i++) {
        references[schemaMainURL + referencedSchemas[i]] =
            referencedSchemaObjects[i];
      }

      if (references.containsKey(ref)) {
        return references[ref];
      }

      return null;
    });

    //Load story schema:
    String storySchemaStr =
        await FileUtils.loadTextFile("assets/schema/story_schema.json");
    var storySchemaObject = jsonDecode(storySchemaStr);

    //Create schema validator:
    jsonValidator = JsonSchema.create(storySchemaObject, refProvider: refProvider);
    return jsonValidator!;
  }
}
