mdown
=====

[![Build Status](https://travis-ci.org/dikmax/mdown.svg?branch=master)](https://travis-ci.org/dikmax/mdown)
[![codecov](https://codecov.io/gh/dikmax/mdown/branch/master/graph/badge.svg)](https://codecov.io/gh/dikmax/mdown)
[![Pub](https://img.shields.io/pub/v/mdown.svg)](https://pub.dartlang.org/packages/mdown)
[![CommonMark spec](https://img.shields.io/badge/commonmark-0.28-green.svg)](http://spec.commonmark.org/)

***mdown*** is fast and [CommonMark][]-compliant Markdown parser.

Basic usage:

```dart
print(markdownToHtml('# Hello world!'));
```

Project main goal is create processing library for Markdown.

Performance
===========

As there are not many Markdown parsers written in Dart out there,
parsing speed is compared with markdown package. [Progit][] was used as
a source of markdown files in different languages. ***mdown*** appears
to be **3** times faster in **VM**, **11** times faster
in **Chrome**, **2.2** times faster in **Safari** and **3.7** times
faster in **Firefox**.

[Run benchmarks yourself or see details.](https://github.com/dikmax/mdown-benchmark)

***mdown*** make extensive use of `String.codeUnitAt` instead
of `RegExp`. So you can see noticeable gain for non-latin languages
(up to &times;38 in Chrome for Japan language).

Extensions
==========

***mdown*** supports some language extensions. You can specify enabled
extensions using options parameter in `markdownToHtml`.

```dart
Options options = const Options(superscript: true);
String res = markdownToHtml('Hello world!\n===', options);
```

There three predefined sets of options:

- `Options.strict`: all extensions, except `rawHtml` are disabled
- `Options.commonmark`: only `smartPunctuation` and `rawHtml` extension
  are enabled.
- `Options.gfm`: `rawHtml`, `tagFilter`, `pipeTables`.
- `Options.defaults`: `smartPunctuation`, `strikeout`, `subscript`,
  `superscript`, `pipeTables`, `texMathDollars`, `rawTex`, `rawHtml`
  are enabled.

To get correspondent parser/writer instance use static getter on class:

```dart
String res = markdownToHtml('Hello world!\n===', Options.strict);
```

If second parameter is not provided, `Options.defaults` is used.

Raw HTML (`Options.rawHtml`)
----------------------------

Allows to include raw HTML blocks. Official CommonMark extension.

Tag filter (`Options.tagFilter`)
--------------------------------

Filters `<textarea>`, `<style>`, `<xmp>`, `<iframe>`, `<noembed>`,
`<noframes>`, `<script>`, `<plaintext>` from HTML output. Works together
with `Options.rawHtml`. Part of [GitHub Flavored Markdown][gfm].

Smart punctuation (`Options.smartPunctuation`)
----------------------------------------------

Smart punctuation is automatic replacement of `...`, `---`, `--`, `"`
and `'` to "…", "—", "–" and curly versions of quote marks accordingly.
It's only official extension to date.

**NOTE:** This extension uses Unicode chars. Make sure that your code
supports it.


Extended attributes for fenced code (`Options.fencedCodeAttributes`)
--------------------------------------------------------------------

Allows fenced code block to have arbitrary extended attributes.

``````md
``` {#someId .class1 .class2 key=value}
code
```
``````

This will be rendered in HTML as

```html
<pre id="someId" class="class1 class2" key="value"><code>code
</code></pre>
```


Extended attributes for headings (`Options.headingAttributes`)
--------------------------------------------------------------

Allows headings to have arbitrary extended attributes.

``````md
# Heading 1 {#someId}

Heading 2 {.someClass}
-------------------
``````

This will be rendered in HTML as

```html
<h1 id="someId">Heading 1</h1>
<h2 class="someClass">Heading 2</h2>
```


Extended attributes for inline code (`Options.inlineCodeAttributes`)
--------------------------------------------------------------------

Adds extended attributes support to inline code.

``````md
`code`{#id .class key='value'}
``````

Extended attributes for links and images (`Options.linkAttributes`)
-------------------------------------------------------------------

Extended attributes for links and images. Both inline and reference
links are supported.

``````md
![](image.jpg){width="800" height="600"}

[test][ref]

[ref]: http://test.com/ {#id}
``````

This will be transformed into:

``````html
<p><img src="image.jpg" alt="" width="800" height="600" /></p>
<p><a href="http://test.com/" id="id">test</a></p>
``````

Strikeout (`Options.strikeout`)
-------------------------------

Strikeouts text (~~like this~~). Just wrap text with double tildes (`~~`).

```md
Strikeouts text (~~like this~~).
```


Subscript (`Options.subscript`)
-------------------------------

Support for subscript (H<sub>2</sub>O). Wrap text with tildes (`~`).

```md
H~2~O
```

Subscript couldn't contain spaces. If you need to insert space into the
subscript, escape space (`\ `).

```md
subscript~with\ spaces~
```


Superscript (`Options.superscript`)
-----------------------------------

Support for superscript (2<sup>2</sup>=4). Wrap text with carets (`^`).

```md
2^2^=4
```

Superscript couldn't contain spaces. If you need to insert space into
superscript, escape space (`\ `).

```md
superscript^with\ spaces^
```


Pipe tables (`Options.pipeTables`)
----------------------------------

Allows to parse tables where cells are separated with vertical bars
(`|`). Compatible with [GitHub table syntax][gfm].

```md
head | cells
-----|------
body | cells
more | cells
```

Also supports cells alignment.

```md
:----|:-----:|----:
left aligned | center aligned | right aligned
```


TeX Math between dollars (`Options.texMathDollars`)
---------------------------------------------------

Anything between two `$` characters will be treated as inline TeX math.
The opening `$` must have a non-space character immediately to its
right, while the closing `$` must have a non-space character immediately
to its left, and must not be followed immediately by a digit. Thus,
`$20,000 and $30,000` won’t parse as math. If for some reason you need
to enclose text in literal `$` characters, backslash-escape them and
they won’t be treated as math delimiters.

Anything between two `$$` will be treated as display TeX math.

HTML writer generates markup for [MathJax][] library. I.e. wraps content
with `\(...\)` or `\[...\]` and additionally wraps it with
`<span class="math inline">` or `<span class="math display">`. If you
need custom classes for `span` you can override them with
`Options.inlineTexMathClasses` and `Options.displayTexMathClasses`.


TeX Math between backslashed `()` or `[]` (`Options.texMathSingleBackslash`)
----------------------------------------------------------------------------

Causes anything between `\(` and `\)` to be interpreted as inline TeX
math and anything between `\[` and `\]` to be interpreted as display
TeX math.

**NOTE 1:** This extension breaks escaping of `(` and `[]`.

**NOTE 2:** This extension is disabled by default.


TeX Math between double backslashed `()` or `[]` (`Options.texMathDoubleBackslash`)
-----------------------------------------------------------------------------------

Causes anything between `\\(` and `\\)` to be interpreted as inline TeX
math and anything between `\\[` and `\\]` to be interpreted as display
TeX math.

**NOTE:** This extension is disabled by default.


Raw TeX (`Options.rawTex`)
--------------------------

Allows to include raw TeX blocks into documents. Right now only
environment blocks are supported. Everything between `\begin{...}` and
`\end{...}` is treated as TeX and passed into resulting HTML as is.


Custom reference resolver
-------------------------

Custom reference resolver may be required when parsing document without
implicitly defined references, for example, Dartdoc.

```dart
/**
 * Throws a [StateError] if ...
 * similar to [anotherMethod], but ...
 */
```

In that case, you could supply parser with the resolver, which should
provide all missing links.

```dart
import 'package:mdown/mdown.dart';
import 'package:mdown/ast/standard_ast_factory.dart';

String library = "mdown";
String version = "0.11.0";
Target linkResolver(String normalizedReference, String reference) {
  if (reference.startsWith("new ")) {
    String className = reference.substring(4);
    return astFactory.target(
        "http://www.dartdocs.org/documentation/$library/$version/index.html#$library/$library.$className@id_$className-",
        null);
  } else {
    return null;
  }
}

String res = markdownToHtml('Hello world!\n===', new Options(linkResolver: linkResolver));
```

[CommonMark]: http://commonmark.org/
[gfm]: https://github.github.com/gfm/
[MathJax]: https://www.mathjax.org/
[Progit]: https://github.com/progit/progit
