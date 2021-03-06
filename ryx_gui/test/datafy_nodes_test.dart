import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/datafy_nodes.dart';

main(){
  Map<int, Node> nodes = {
    0: Node(
        toolId: 0,
        x: 0,
        y: 0,
        width: 10,
        height: 10,
        plugin: 'InputOutput',
        storedMacro: '',
        foundMacro: '',
        category: 'Tool',
    ),
    1: Node(
      toolId: 1,
      x: 10,
      y: 10,
      width: 20,
      height: 20,
      plugin: 'InputsOutputs',
      storedMacro: '',
      foundMacro: '',
      category: 'Tool',
    ),
    2: Node(
      toolId: 2,
      x: 10,
      y: 10,
      width: 20,
      height: 20,
      plugin: '',
      storedMacro: 'ABC',
      foundMacro: 'ABC',
      category: 'Tool',
    ),
  };
  Map<String, ToolData> toolData = {
    'InputOutput': ToolData(
      inputs: ['Input'],
      outputs: ['Output'],
    ),
    'InputsOutputs': ToolData(
      inputs: ['Input1', 'Input2'],
      outputs: ['Output1','Output2'],
    ),
    'ABC': ToolData(
      inputs: ['ABCIn'],
      outputs: ['ABCOut'],
    ),
  };

  test("Add tool data to nodes", (){
    var enriched = datafyNodes(nodes, toolData);
    expect(enriched[0].getInput('Input'), equals(Offset(0, 5)));
    expect(enriched[0].getOutput('Output'), equals(Offset(10, 5)));

    expect(enriched[1].getInput('Input1'), equals(Offset(10, 10+(20/3))));
    expect(enriched[1].getOutput('Output1'), equals(Offset(30, 10+(20/3))));
    expect(enriched[1].getInput('Input2'), equals(Offset(10, 10+(20/3*2))));
    expect(enriched[1].getOutput('Output2'), equals(Offset(30, 10+(20/3*2))));

    expect(enriched[2].getInput('ABCIn'), equals(Offset(10, 20)));
    expect(enriched[2].getOutput('ABCOut'), equals(Offset(30, 20)));
  });

  test("Invalid inputs/outputs return top left/right corners",(){
    var enriched = datafyNodes(nodes, toolData);
    expect(enriched[0].getInput('Invalid'), equals(Offset(0,0)));
    expect(enriched[0].getOutput('Invalid'), equals(Offset(10,0)));

    expect(enriched[1].getInput('Invalid'), equals(Offset(10,10)));
    expect(enriched[1].getOutput('Invalid'), equals(Offset(30,10)));

    expect(enriched[2].getInput('Invalid'), equals(Offset(10,10)));
    expect(enriched[2].getOutput('Invalid'), equals(Offset(30,10)));
  });

  test("Add tool data to node with invalid plugin",(){
    Map<int, Node> nodes = {
      0: Node(
          toolId: 0,
          x: 0,
          y: 0,
          width: 10,
          height: 10,
          plugin: 'Invalid',
          storedMacro: '',
          foundMacro: '',
          category: 'Tool',
      ),
    };
    var enriched = datafyNodes(nodes, toolData);
    expect(enriched[0].getInput('Input'), equals(Offset(0,0)));
    expect(enriched[0].getOutput('Output'), equals(Offset(10,0)));
  });

  test("Endpoint for retrieving the full list of inputs and outputs",(){
    var enriched = datafyNodes(nodes, toolData);
    expect(enriched[0].allInputs.length, equals(1));
    expect(enriched[0].allOutputs.length, equals(1));
    expect(enriched[1].allInputs.length, equals(2));
    expect(enriched[1].allOutputs.length, equals(2));
    expect(enriched[2].allInputs.length, equals(1));
    expect(enriched[2].allOutputs.length, equals(1));
  });

  test("Interface anchors are available and positioned properly", (){
    var enriched = datafyNodes(nodes, toolData);
    expect(enriched[0].getInterfaceIn('Condition'), equals(Offset(10*(1/3)+0, 0)));
    expect(enriched[0].getInterfaceIn('Question'), equals(Offset(10*(2/3)+0, 0)));
    expect(enriched[0].getInterfaceIn('Question Input'), equals(Offset(5, 0)));
    expect(enriched[0].getInterfaceIn('Action'), equals(Offset(5, 0)));

    expect(enriched[0].getInterfaceOut('Question'), equals(Offset(5, 10)));
    expect(enriched[0].getInterfaceOut('Action'), equals(Offset(5, 10)));
    expect(enriched[0].getInterfaceOut('True Condition'), equals(Offset(10*(1/3)+0, 10)));
    expect(enriched[0].getInterfaceOut('False Condition'), equals(Offset(10*(2/3)+0, 10)));
  });

  test("Invalid interface anchors return null",(){
    var enriched = datafyNodes(nodes, toolData);
    expect(enriched[0].getInterfaceIn('Invalid'), isNull);
    expect(enriched[0].getInterfaceOut('Invalid'), isNull);
  });
}

/*
InterfaceIn
	Condition (left)
	Question (right)
	Question Input (middle)
	Action (middle)

InterfaceOut
	Question (middle)
	Action (middle)
	True Condition (left)
	False Condition (right)
 */