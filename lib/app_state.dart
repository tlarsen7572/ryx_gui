import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/bloc_state.dart';
import 'package:rxdart/rxdart.dart';

class AppState extends BlocState{
  AppState(Io io){
    _communicator = Communicator(io);
  }

  Communicator _communicator;

  var _toolData = BehaviorSubject<Map<String,ToolData>>.seeded(null);
  Stream<Map<String,ToolData>> get toolData => _toolData.stream;
  Map<String,ToolData> get currentTools => _toolData.value;

  var _folders = BehaviorSubject<List<String>>.seeded(null);
  Stream<List<String>> get folders => _folders.stream;

  var _currentFolder = BehaviorSubject<String>.seeded("");
  Stream<String> get currentFolder => _currentFolder.distinct();

  var _currentProject = BehaviorSubject<String>.seeded("");
  Stream<String> get currentProject => _currentProject.stream;

  var _projectStructure = BehaviorSubject<ProjectStructure>.seeded(null);
  Stream<ProjectStructure> get projectStructure => _projectStructure.stream;

  var _isLoadingProject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingProject => _isLoadingProject.stream;

  var _currentDocument = BehaviorSubject<String>.seeded("");
  Stream<String> get currentDocument => _currentDocument.stream;

  var _isLoadingDocument = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingDocument => _isLoadingDocument.stream;

  var _documentStructure = BehaviorSubject<DocumentStructure>.seeded(null);
  Stream<DocumentStructure> get documentStructure => _documentStructure.stream;

  Future<String> browseFolder(String root) async {
    var response = await _communicator.browseFolder(root);
    if (response.success){
      _currentFolder.add(root);
      _folders.add(response.value);
    }
    return response.error;
  }

  Future<String> getProjectStructure(String project) async {
    _isLoadingProject.add(true);
    var toolDataResponse = await _communicator.getToolData();
    if (!toolDataResponse.success){
      _isLoadingProject.add(false);
      return toolDataResponse.error;
    }
    _toolData.add(toolDataResponse.value);

    var structureResponse = await _communicator.getProjectStructure(project);
    if (structureResponse.success){
      _projectStructure.add(structureResponse.value);
      _currentProject.add(project);
    }
    _isLoadingProject.add(false);
    return structureResponse.error;
  }

  Future<String> getDocumentStructure(String document) async {
    _isLoadingDocument.add(true);
    var project = _currentProject.value;
    if (project == ''){
      _isLoadingDocument.add(false);
      return "no project was open";
    }
    var response = await _communicator.getDocumentStructure(project, document);
    if (response.success){
      _documentStructure.add(response.value);
      _currentDocument.add(document);
    }
    _isLoadingDocument.add(false);
    return response.error;
  }

  void clearFolder() async {
    _currentFolder.add("");
    _folders.add(null);
  }

  Future initialize() async {

  }

  void dispose() {
    _folders.close();
    _currentFolder.close();
    _currentProject.close();
    _projectStructure.close();
    _isLoadingProject.close();
    _currentDocument.close();
    _isLoadingDocument.close();
    _documentStructure.close();
    _toolData.close();
  }
}
