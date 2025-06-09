String addPostposition(String word, String josa1, String josa2) {
  final lastChar = word.codeUnitAt(word.length - 1);
  final hasBatchim = (lastChar - 0xAC00) % 28 != 0;
  return word + (hasBatchim ? josa1 : josa2);
}
