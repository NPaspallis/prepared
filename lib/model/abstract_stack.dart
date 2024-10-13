class AbstractStack<T> {

  final List<T> _data = [];

  ///Returns the length of the stack.
  int length() {
    return _data.length;
  }

  ///Returns whether the stack is empty.
  bool isEmpty() {
    return _data.isEmpty;
  }

  ///Returns whether the stack is not empty.
  bool isNotEmpty() {
    return _data.isNotEmpty;
  }

  ///Pushes an element into the stack.
  void push(T element) {
    _data.add(element);
  }

  ///Pops an element from the stack.
  T? pop() {
    if (isNotEmpty()) {
      return _data.removeLast();
    }
    throw Exception("Cannot pop element from empty stack.");
  }

  ///Peeks at the element at the top of the stack.
  T peek() {
    if (isNotEmpty()) {
      return _data.last;
    }
    throw Exception("Cannot peek at top of an empty stack.");
  }

  ///Clears the stack.
  void clear() {
    _data.clear();
  }

  ///Returns the contents of the stack as a list.
  List<T> asList() {
    List<T> returnedList = [];
    returnedList.addAll(_data);
    return returnedList;
  }

}