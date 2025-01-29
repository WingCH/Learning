import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

// dart run example/study_abstract_syntax_tree_example.dart

// Custom AST Visitor
class MethodVisitor extends RecursiveAstVisitor<void> {
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    print('Found method: ${node.name}');
    super.visitMethodDeclaration(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    print('Found variable: ${node.name}');
    super.visitVariableDeclaration(node);
  }
}

void main() {
  // Example source code
  const sourceCode = '''
  class ExampleClass {
    final int a = 1;
    void printMessage(String message) {
      print(message);
    }
    
    int calculateSum(int a, int b) {
      return a + b;
    }
  }
  ''';

  // Parse source code into AST
  final parser = parseString(content: sourceCode);
  final compilationUnit = parser.unit;

  // Traverse AST with custom visitor
  final visitor = MethodVisitor();
  compilationUnit.visitChildren(visitor);
}
