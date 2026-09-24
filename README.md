# @simatic-ax/regax

## Description

The `@simatic-ax/regax` library provides a set of tools and utilities for working with regular expressions in ST (Structured Text) programming. It simplifies the process of pattern matching, searching, and manipulating strings within your ST code, making it easier to handle complex text processing tasks.

## Getting started

Install with Apax:

> If you have not already done so, log in to the GitHub registry first.
> More information is available [here](https://github.com/simatic-ax/.github/blob/main/docs/personalaccesstoken.md).

```cli
apax add @simatic-ax/regax
```

Add the namespace in your ST code:

```iec-st
Using Simatic.Ax.RegAx;
```

## Classes

| Classes | Description |
|---------|-------------|
| `Regex` | Provides iterative pattern matching for a deliberately small regex subset in ST code. |

### Methods

#### `Match`

Checks the previously assigned input against the previously assigned pattern and stores the matched text.

#### `MatchNext`

Continues searching after the previous successful unanchored match and stores the next matched text.

#### `SetPattern`

```iec-st
METHOD SetPattern
VAR_INPUT
    pattern : STRING;
END_VAR
```

- **Description**: Sets the regular expression pattern to be used for subsequent operations.
- **Parameters**:
  - `pattern`: The regular expression pattern to set.
- **Returns**: None.

#### `SetInput`

```iec-st
METHOD SetInput
VAR_INPUT
    input : STRING;
END_VAR
```

- **Description**: Sets the input string to be used for subsequent operations.
- **Parameters**:
  - `input`: The string to set as input.
- **Returns**: None.

#### `GetMatch`

Returns the text of the last successful match.

#### `GetMatchStartIndex`

Returns the 1-based start index of the last successful match.

#### `GetMatchEndIndex`

Returns the 1-based end index of the last successful match.

## Examples

### Exact match

```iec-st
VAR
  regex : Regex;
  matched : BOOL;
END_VAR

regex.SetPattern('^abc$$');
regex.SetInput('abc');

matched := regex.Match();
// matched = TRUE
// regex.GetMatch() = 'abc'
```

### No match

```iec-st
VAR
  regex : Regex;
  matched : BOOL;
END_VAR

regex.SetPattern('^abc$$');
regex.SetInput('abx');

matched := regex.Match();
// matched = FALSE
// regex.GetMatch() = ''
```

### Find an IP address inside a URL

```iec-st
VAR
  regex : Regex;
  matched : BOOL;
END_VAR

regex.SetPattern('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
regex.SetInput('https://192.168.0.1:5050');

matched := regex.Match();
// matched = TRUE
// regex.GetMatch() = '192.168.0.1'
```

### Iterate over all IP blocks with `MatchNext`

```iec-st
VAR
  regex : Regex;
END_VAR

regex.SetPattern('\d{1,3}');
regex.SetInput('https://192.168.0.1');

IF regex.Match() THEN
  // regex.GetMatch() = '192'
  // regex.GetMatchStartIndex() = 9
  // regex.GetMatchEndIndex() = 11
END_IF;

IF regex.MatchNext() THEN
  // regex.GetMatch() = '168'
END_IF;

IF regex.MatchNext() THEN
  // regex.GetMatch() = '0'
END_IF;

IF regex.MatchNext() THEN
  // regex.GetMatch() = '1'
END_IF;
```

## Regular Expressions

The `Regex` class in the `@simatic-ax/regax` library currently supports a small, iterative regex subset that is compatible with SIMATIC AX/ST constraints.

### Supported patterns

- **Literal Characters**: Matches the exact characters in the pattern.
  - `abc` matches `abc` in the input string.

- **Predefined Character Classes**:
  - `\d`: Matches any digit (0-9).
  - `\w`: Matches any word character (alphanumeric plus underscore).

- **Character Classes**:
  - `[abc]`: Matches one of the listed characters.
  - `[a-z]`: Matches a character inside the specified range.
  - `[^abc]`: Matches one character that is not listed in the class.

- **Anchors**:
  - `^`: Matches the start of the string.
  - `$`: Matches the end of the string.

- **Quantifiers**:
  - `*`: Matches 0 or more occurrences of the preceding element.
  - `+`: Matches 1 or more occurrences of the preceding element.
  - `?`: Matches 0 or 1 occurrence of the preceding element.
  - `{n}`: Matches exactly `n` occurrences of the preceding element.
  - `{n,}`: Matches `n` or more occurrences of the preceding element.
  - `{n,m}`: Matches between n and m occurrences of the preceding element.

- **Escaped Literals**:
  - `\.` matches a literal dot.
  - `\+` matches a literal plus sign.

### Matching behavior

- `Match()` returns the first match.
- Without `^` and `$`, the engine searches inside the input string.
- `MatchNext()` continues after the previous successful unanchored match.
- `MatchNext()` is intended for unanchored patterns. Anchored patterns like `^abc$$` only support `Match()`.

### Current limitation: no backtracking

The current matcher is iterative and greedy, but it does not implement backtracking.
This matters when a quantified token like `+`, `*`, `{n,}` or `{n,m}` is followed by a later literal or token that would require the matcher to step back.

In practice, patterns with a broad token followed by a fixed separator may fail even though they would match in more complete regex engines.

Examples:

- `^[\w]+@[\w]+\.[a-z]{2,3}$$` does **not** currently match `john_doe@factory.de`
  because `[\w]+` greedily consumes too much before `@` and the matcher does not backtrack.
- `^http://[\w]+\.local:\d{4}$$` does **not** currently match `http://plc01.local:8080`
  because `[\w]+` greedily consumes the host part and does not step back before `.local`.
- `^[a-z]+\.[a-z]{3}$$` may fail for inputs where the first `+` would need to give back characters to satisfy the extension part.

Workaround:

- Prefer fixed-width or more specific patterns before separators, for example `^plc\d{2}$$` instead of a broad `[\w]+` segment when the expected format is known.
- Split complex validations into multiple simpler regex checks if a later literal depends on an earlier greedy token.

### Currently not supported patterns

- **Groups and Alternation**:
  - `(ab)`
  - `a|b`

- **Predefined Character Classes**:
  - `\D`: Matches any non-digit.
  - `\W`: Matches any non-word character.
  - `\s`: Matches any whitespace character.
  - `\S`: Matches any non-whitespace character.

## Contribution

Thanks for your interest in contributing. Anyone can report bugs, unclear documentation, and other problems in the Issues section or, even better, propose changes to this repository using merge requests.

## License and Legal information

Please read the [Legal information](LICENSE.md)
