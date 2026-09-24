USING System.Strings;

NAMESPACE Simatic.Ax.RegAx

    /// Public regex facade for configuring a pattern, assigning input and retrieving the match.
    CLASS PUBLIC Regex
        VAR
            /// Pattern used for the next match operation.
            _pattern : STRING;

            /// Input string used for the next match operation.
            _input : STRING;

            /// Last matched substring.
            _match : STRING;

            /// 1-based start index of the last successful match.
            _matchStartIndex : INT;

            /// 1-based end index of the last successful match.
            _matchEndIndex : INT;

            /// Next input position used by MatchNext.
            _nextSearchStartIndex : INT;

            /// Internal tokenizer instance.
            _tokenizer : RegexTokenizer;

            /// Internal matcher instance.
            _matcher : RegexMatcher;
        END_VAR

        /// Stores the regex pattern for subsequent Match calls.
        METHOD PUBLIC SetPattern
            VAR_INPUT
                /// Regex pattern to evaluate.
                pattern : STRING;
            END_VAR
            _pattern := pattern;
        END_METHOD

        /// Stores the input string for subsequent Match calls.
        METHOD PUBLIC SetInput
            VAR_INPUT
                /// Input string to search in.
                inputStr : STRING;
            END_VAR
            _input := inputStr;
            _match := '';
            _matchStartIndex := 0;
            _matchEndIndex := 0;
            _nextSearchStartIndex := 1;
        END_METHOD

        /// Evaluates the configured pattern against the configured input.
        METHOD PUBLIC Match : BOOL
            VAR
                tokens : ARRAY[1..64] OF RegexToken;
                tokenCount : INT;
                anchorStart : BOOL;
                anchorEnd : BOOL;
                inputLength : INT;
                startIndex : INT;
                endIndex : INT;
            END_VAR

            _match := '';
            _matchStartIndex := 0;
            _matchEndIndex := 0;
            _nextSearchStartIndex := 1;
            IF NOT _tokenizer.Tokenize(pattern := _pattern, tokens => tokens, tokenCount => tokenCount, anchorStart => anchorStart, anchorEnd => anchorEnd) THEN
                Match := FALSE;
                RETURN;
            END_IF;

            inputLength := LengthOf(_input);
            IF tokenCount <= 0 THEN
                Match := FALSE;
                RETURN;
            END_IF;

            IF anchorStart THEN
                startIndex := 1;
                IF _matcher.TryMatchFrom(input := _input, startIndex := startIndex, inputLength := inputLength, tokens := tokens, tokenCount := tokenCount, anchorEnd := anchorEnd, endIndex => endIndex) THEN
                    _match := _matcher.BuildMatch(input := _input, startIndex := startIndex, endIndex := endIndex);
                    _matchStartIndex := startIndex;
                    _matchEndIndex := endIndex;
                    _nextSearchStartIndex := endIndex + 1;
                    Match := TRUE;
                    RETURN;
                END_IF;
                Match := FALSE;
                RETURN;
            END_IF;

            startIndex := 1;
            WHILE startIndex <= inputLength DO
                IF _matcher.TryMatchFrom(input := _input, startIndex := startIndex, inputLength := inputLength, tokens := tokens, tokenCount := tokenCount, anchorEnd := anchorEnd, endIndex => endIndex) THEN
                    _match := _matcher.BuildMatch(input := _input, startIndex := startIndex, endIndex := endIndex);
                    _matchStartIndex := startIndex;
                    _matchEndIndex := endIndex;
                    _nextSearchStartIndex := endIndex + 1;
                    Match := TRUE;
                    RETURN;
                END_IF;
                startIndex := startIndex + 1;
            END_WHILE;

            Match := FALSE;
        END_METHOD

        /// Continues searching after the previous successful match.
        METHOD PUBLIC MatchNext : BOOL
            VAR
                tokens : ARRAY[1..64] OF RegexToken;
                tokenCount : INT;
                anchorStart : BOOL;
                anchorEnd : BOOL;
                inputLength : INT;
                startIndex : INT;
                endIndex : INT;
            END_VAR

            _match := '';
            _matchStartIndex := 0;
            _matchEndIndex := 0;

            IF NOT _tokenizer.Tokenize(pattern := _pattern, tokens => tokens, tokenCount => tokenCount, anchorStart => anchorStart, anchorEnd => anchorEnd) THEN
                MatchNext := FALSE;
                RETURN;
            END_IF;

            IF anchorStart OR anchorEnd THEN
                MatchNext := FALSE;
                RETURN;
            END_IF;

            inputLength := LengthOf(_input);
            startIndex := _nextSearchStartIndex;
            IF startIndex < 1 THEN
                startIndex := 1;
            END_IF;

            WHILE startIndex <= inputLength DO
                IF _matcher.TryMatchFrom(input := _input, startIndex := startIndex, inputLength := inputLength, tokens := tokens, tokenCount := tokenCount, anchorEnd := FALSE, endIndex => endIndex) THEN
                    _match := _matcher.BuildMatch(input := _input, startIndex := startIndex, endIndex := endIndex);
                    _matchStartIndex := startIndex;
                    _matchEndIndex := endIndex;
                    _nextSearchStartIndex := endIndex + 1;
                    MatchNext := TRUE;
                    RETURN;
                END_IF;
                startIndex := startIndex + 1;
            END_WHILE;

            MatchNext := FALSE;
        END_METHOD

        /// Returns the substring captured by the last successful Match call.
        METHOD PUBLIC GetMatch : STRING
            GetMatch := _match;
        END_METHOD

        /// Returns the 1-based start index of the last successful match.
        METHOD PUBLIC GetMatchStartIndex : INT
            GetMatchStartIndex := _matchStartIndex;
        END_METHOD

        /// Returns the 1-based end index of the last successful match.
        METHOD PUBLIC GetMatchEndIndex : INT
            GetMatchEndIndex := _matchEndIndex;
        END_METHOD
    END_CLASS

END_NAMESPACE
