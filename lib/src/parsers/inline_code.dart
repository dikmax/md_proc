part of md_proc.src.parsers;

class InlineCodeParser extends AbstractParser<Inlines> {
  InlineCodeParser(ParsersContainer container) : super(container);

  @override
  ParseResult<Inlines> parse(String text, int offset) {
    if (text.codeUnitAt(offset) != _BACKTICK_CODE_UNIT) {
      return new ParseResult<Inlines>.failure();
    }

    int fenceSize = 1;
    offset++;

    // Finite Automata
    // TODO use constants for states.
    int state = 0;
    int length = text.length;
    int codeStartOffset = -1;
    int endFenceSize = 0;
    int codeEndOffset = -1;
    while (offset < length) {
      int codeUnit = text.codeUnitAt(offset);

      switch (state) {
        case 0:
          // Parsing open fence.
          if (codeUnit == _BACKTICK_CODE_UNIT) {
            fenceSize++;
          } else {
            state = 1;
            codeStartOffset = offset;
          }
          break;

        case 1:
          // Parsing code
          if (codeUnit == _BACKTICK_CODE_UNIT) {
            codeEndOffset = offset;
            endFenceSize = 1;
            state = 2;
          }

          break;

        case 2:
          // Parsing end
          if (codeUnit == _BACKTICK_CODE_UNIT) {
            endFenceSize++;
          } else if (endFenceSize == fenceSize) {
            state = 3;
          } else {
            state = 1;
          }
          break;
      }

      if (state == 3) {
        // Done.
        break;
      }

      offset++;
    }

    if (state == 3 || (state == 2 && endFenceSize == fenceSize)) {
      String code =
          _trimAndReplaceSpaces(text.substring(codeStartOffset, codeEndOffset));
      return new ParseResult<Inlines>.success(
          new Inlines.single(new Code(code, fenceSize: fenceSize)), offset);
    }

    return new ParseResult<Inlines>.success(
        new Inlines.single(new Str('`' * fenceSize)),
        codeStartOffset == -1 ? offset : codeStartOffset);
  }
}
