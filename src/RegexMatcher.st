USING System.Strings;

NAMESPACE Simatic.Ax.RegAx

    {axcode:docs-v0:@simatic-ax/regax:Regex.md}
    /// Internal matcher for the supported iterative regex subset.
    CLASS INTERNAL RegexMatcher
        VAR CONSTANT
            /// Maximum length of a returned match.
            MAX_MATCH_LENGTH : INT := 254;
        END_VAR

        /// Tries to match a tokenized pattern against the input string.
        METHOD PUBLIC MatchTokens : BOOL
            VAR_INPUT
                /// Input string to search in.
                input : STRING;

                /// Tokenized regex pattern.
                tokens : ARRAY[1..64] OF RegexToken;

                /// Number of valid tokens.
                tokenCount : INT;

                /// TRUE when matching must start at the beginning of the input.
                anchorStart : BOOL;

                /// TRUE when matching must end at the end of the input.
                anchorEnd : BOOL;
            END_VAR
            VAR_OUTPUT
                /// Matched substring when a match is found.
                matchedText : STRING;
            END_VAR
            VAR
                inputLength : INT;
                startIndex : INT;
                endIndex : INT;
            END_VAR

            MatchTokens := FALSE;
            matchedText := '';
            inputLength := LengthOf(input);

            IF tokenCount <= 0 THEN
                RETURN;
            END_IF;

            IF anchorStart THEN
                startIndex := 1;
                IF THIS.TryMatchFrom(input := input, startIndex := startIndex, inputLength := inputLength, tokens := tokens, tokenCount := tokenCount, anchorEnd := anchorEnd, endIndex => endIndex) THEN
                    matchedText := THIS.BuildMatch(input := input, startIndex := startIndex, endIndex := endIndex);
                    MatchTokens := TRUE;
                END_IF;
                RETURN;
            END_IF;

            startIndex := 1;
            WHILE startIndex <= inputLength DO
                IF THIS.TryMatchFrom(input := input, startIndex := startIndex, inputLength := inputLength, tokens := tokens, tokenCount := tokenCount, anchorEnd := anchorEnd, endIndex => endIndex) THEN
                    matchedText := THIS.BuildMatch(input := input, startIndex := startIndex, endIndex := endIndex);
                    MatchTokens := TRUE;
                    RETURN;
                END_IF;
                startIndex := startIndex + 1;
            END_WHILE;
        END_METHOD

        /// Attempts a match from a specific input position.
        METHOD INTERNAL TryMatchFrom : BOOL
            VAR_INPUT
                /// Input string to search in.
                input : STRING;

                /// 1-based start position for this attempt.
                startIndex : INT;

                /// Cached input length.
                inputLength : INT;

                /// Tokenized regex pattern.
                tokens : ARRAY[1..64] OF RegexToken;

                /// Number of valid tokens.
                tokenCount : INT;

                /// TRUE when the match must consume the full remaining input.
                anchorEnd : BOOL;
            END_VAR
            VAR_OUTPUT
                /// Inclusive end index of the match.
                endIndex : INT;
            END_VAR
            VAR
                tokenIndex : INT;
                inputIndex : INT;
                repeatCount : INT;
                maxAllowed : INT;
            END_VAR

            TryMatchFrom := FALSE;
            endIndex := startIndex - 1;
            inputIndex := startIndex;

            FOR tokenIndex := 1 TO tokenCount DO
                repeatCount := 0;
                maxAllowed := tokens[tokenIndex].maxCount;

                WHILE repeatCount < maxAllowed AND inputIndex <= inputLength DO
                    IF THIS.TokenMatches(token := tokens[tokenIndex], currentChar := input[inputIndex]) THEN
                        repeatCount := repeatCount + 1;
                        inputIndex := inputIndex + 1;
                    ELSE
                        EXIT;
                    END_IF;
                END_WHILE;

                IF repeatCount < tokens[tokenIndex].minCount THEN
                    RETURN;
                END_IF;
            END_FOR;

            endIndex := inputIndex - 1;
            IF anchorEnd AND endIndex <> inputLength THEN
                RETURN;
            END_IF;

            TryMatchFrom := TRUE;
        END_METHOD

        /// Checks whether a single input character satisfies a token.
        METHOD PRIVATE TokenMatches : BOOL
            VAR_INPUT
                /// Token to evaluate.
                token : RegexToken;

                /// Current input character.
                currentChar : CHAR;
            END_VAR
            VAR
                literalIndex : INT;
                rangeIndex : INT;
                isMatch : BOOL;
            END_VAR
            CASE token.tokenType OF
                RegexTokenType#Literal, RegexTokenType#EscapedLiteral:
                    TokenMatches := currentChar = token.literal;
                RegexTokenType#DigitClass:
                    TokenMatches := (currentChar >= '0') AND (currentChar <= '9');
                RegexTokenType#WordClass:
                    TokenMatches := ((currentChar >= 'A') AND (currentChar <= 'Z')) OR ((currentChar >= 'a') AND (currentChar <= 'z')) OR ((currentChar >= '0') AND (currentChar <= '9')) OR (currentChar = '_');
                RegexTokenType#CharacterClass:
                    isMatch := FALSE;
                    FOR literalIndex := 1 TO token.charClass.literalCount DO
                        IF currentChar = token.charClass.literals[literalIndex] THEN
                            isMatch := TRUE;
                            EXIT;
                        END_IF;
                    END_FOR;
                    IF NOT isMatch THEN
                        FOR rangeIndex := 1 TO token.charClass.rangeCount DO
                            IF (currentChar >= token.charClass.ranges[rangeIndex].rangeStart) AND (currentChar <= token.charClass.ranges[rangeIndex].rangeEnd) THEN
                                isMatch := TRUE;
                                EXIT;
                            END_IF;
                        END_FOR;
                    END_IF;
                    IF token.charClass.isNegated THEN
                        TokenMatches := NOT isMatch;
                    ELSE
                        TokenMatches := isMatch;
                    END_IF;
            ELSE
                TokenMatches := FALSE;
            END_CASE;
        END_METHOD

        /// Builds the matched substring from the input indices.
        METHOD INTERNAL BuildMatch : STRING
            VAR_INPUT
                /// Source input string.
                input : STRING;

                /// Inclusive start index of the match.
                startIndex : INT;

                /// Inclusive end index of the match.
                endIndex : INT;
            END_VAR
            VAR
                currentIndex : INT;
                result : STRING;
            END_VAR

            result := '';
            IF endIndex < startIndex THEN
                BuildMatch := result;
                RETURN;
            END_IF;

            FOR currentIndex := startIndex TO endIndex DO
                result := CONCAT(result, input[currentIndex]);
            END_FOR;
            BuildMatch := result;
        END_METHOD
    END_CLASS

END_NAMESPACE