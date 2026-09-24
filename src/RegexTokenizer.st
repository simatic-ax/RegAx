USING System.Strings;

NAMESPACE Simatic.Ax.RegAx

    /// Converts a pattern string into validated regex tokens.
    CLASS INTERNAL RegexTokenizer
        VAR CONSTANT
            /// Maximum number of tokens supported per pattern.
            MAX_TOKEN_COUNT : INT := 64;

            /// Maximum repetition count used for open-ended quantifiers.
            MAX_REPEAT_COUNT : INT := 254;
        END_VAR

        /// Tokenizes the configured regex pattern and extracts anchors.
        METHOD PUBLIC Tokenize : BOOL
            VAR_INPUT
                /// Pattern string to parse.
                pattern : STRING;
            END_VAR
            VAR_OUTPUT
                /// Parsed token sequence.
                tokens : ARRAY[1..64] OF RegexToken;

                /// Number of valid entries in tokens.
                tokenCount : INT;

                /// TRUE when the pattern starts with ^.
                anchorStart : BOOL;

                /// TRUE when the pattern ends with $.
                anchorEnd : BOOL;
            END_VAR
            VAR
                patternLength : INT;
                patternIndex : INT;
                currentChar : CHAR;
                nextChar : CHAR;
                token : RegexToken;
                quantifierStart : INT;
                quantifierEnd : INT;
                repeatMin : INT;
                repeatMax : INT;
                charClassEnd : INT;
            END_VAR

            Tokenize := FALSE;
            tokenCount := 0;
            anchorStart := FALSE;
            anchorEnd := FALSE;
            patternLength := LengthOf(pattern);

            IF patternLength = 0 THEN
                RETURN;
            END_IF;

            patternIndex := 1;
            WHILE patternIndex <= patternLength DO
                currentChar := pattern[patternIndex];

                IF currentChar = '^' THEN
                    IF patternIndex <> 1 THEN
                        RETURN;
                    END_IF;
                    anchorStart := TRUE;
                    patternIndex := patternIndex + 1;
                    CONTINUE;
                END_IF;

                IF currentChar = CHAR#36 THEN
                    IF patternIndex <> patternLength THEN
                        RETURN;
                    END_IF;
                    anchorEnd := TRUE;
                    patternIndex := patternIndex + 1;
                    CONTINUE;
                END_IF;

                token.tokenType := RegexTokenType#None;
                token.literal := CHAR#0;
                token.minCount := 1;
                token.maxCount := 1;
                token.charClass.isNegated := FALSE;
                token.charClass.literalCount := 0;
                token.charClass.rangeCount := 0;

                IF currentChar = CHAR#92 THEN
                    IF patternIndex >= patternLength THEN
                        RETURN;
                    END_IF;

                    patternIndex := patternIndex + 1;
                    nextChar := pattern[patternIndex];
                    CASE nextChar OF
                        'd':
                            token.tokenType := RegexTokenType#DigitClass;
                        'w':
                            token.tokenType := RegexTokenType#WordClass;
                        CHAR#46, CHAR#92, CHAR#94, CHAR#36, CHAR#43, CHAR#63, CHAR#123, CHAR#125, CHAR#40, CHAR#41, CHAR#91, CHAR#93, CHAR#124, CHAR#42:
                            token.tokenType := RegexTokenType#EscapedLiteral;
                            token.literal := nextChar;
                    ELSE
                        RETURN;
                    END_CASE;
                ELSIF currentChar = '[' THEN
                    IF NOT THIS.ParseCharacterClass(pattern := pattern, startIndex := patternIndex, token := token, endIndex => charClassEnd) THEN
                        RETURN;
                    END_IF;
                    patternIndex := charClassEnd;
                ELSIF THIS.IsReserved(currentChar := currentChar) THEN
                    RETURN;
                ELSE
                    token.tokenType := RegexTokenType#Literal;
                    token.literal := currentChar;
                END_IF;

                IF token.tokenType = RegexTokenType#None THEN
                    RETURN;
                END_IF;

                IF tokenCount >= MAX_TOKEN_COUNT THEN
                    RETURN;
                END_IF;

                IF patternIndex < patternLength THEN
                    nextChar := pattern[patternIndex + 1];
                    CASE nextChar OF
                        '?':
                            token.minCount := 0;
                            token.maxCount := 1;
                            patternIndex := patternIndex + 1;
                        '+':
                            token.minCount := 1;
                            token.maxCount := MAX_REPEAT_COUNT;
                            patternIndex := patternIndex + 1;
                        '*':
                            token.minCount := 0;
                            token.maxCount := MAX_REPEAT_COUNT;
                            patternIndex := patternIndex + 1;
                        '{':
                            quantifierStart := patternIndex + 1;
                            IF NOT THIS.ParseQuantifier(pattern := pattern, startIndex := quantifierStart, endIndex => quantifierEnd, repeatMin => repeatMin, repeatMax => repeatMax) THEN
                                RETURN;
                            END_IF;
                            token.minCount := repeatMin;
                            token.maxCount := repeatMax;
                            patternIndex := quantifierEnd;
                    END_CASE;
                END_IF;

                tokenCount := tokenCount + 1;
                tokens[tokenCount] := token;
                patternIndex := patternIndex + 1;
            END_WHILE;

            Tokenize := tokenCount > 0;
        END_METHOD

        /// Returns TRUE for syntax characters that are not accepted as plain literals.
        METHOD PRIVATE IsReserved : BOOL
            VAR_INPUT
                currentChar : CHAR;
            END_VAR
            CASE currentChar OF
                '?', '+', '*', '{', '}', '(', ')', '[', ']', '|':
                    IsReserved := TRUE;
            ELSE
                IsReserved := FALSE;
            END_CASE;
        END_METHOD

        /// Parses a bounded or open-ended repetition quantifier.
        METHOD PRIVATE ParseQuantifier : BOOL
            VAR_INPUT
                /// Full pattern string.
                pattern : STRING;

                /// Index of the opening { character.
                startIndex : INT;
            END_VAR
            VAR_OUTPUT
                /// Index of the closing } character.
                endIndex : INT;

                /// Minimum repetition count.
                repeatMin : INT;

                /// Maximum repetition count.
                repeatMax : INT;
            END_VAR
            VAR
                patternLength : INT;
                currentIndex : INT;
                currentChar : CHAR;
                hasComma : BOOL;
                hasMinDigit : BOOL;
                hasMaxDigit : BOOL;
            END_VAR

            ParseQuantifier := FALSE;
            repeatMin := 0;
            repeatMax := 0;
            endIndex := 0;
            patternLength := LengthOf(pattern);

            IF pattern[startIndex] <> '{' THEN
                RETURN;
            END_IF;

            currentIndex := startIndex + 1;
            WHILE currentIndex <= patternLength DO
                currentChar := pattern[currentIndex];
                IF currentChar >= '0' AND currentChar <= '9' THEN
                    hasMinDigit := TRUE;
                    repeatMin := repeatMin * 10 + (TO_INT(TO_BYTE(currentChar)) - 48);
                    currentIndex := currentIndex + 1;
                ELSE
                    EXIT;
                END_IF;
            END_WHILE;

            IF NOT hasMinDigit THEN
                RETURN;
            END_IF;

            IF currentIndex > patternLength THEN
                RETURN;
            END_IF;

            currentChar := pattern[currentIndex];
            IF currentChar = '}' THEN
                repeatMax := repeatMin;
                endIndex := currentIndex;
                ParseQuantifier := TRUE;
                RETURN;
            END_IF;

            IF currentChar <> ',' THEN
                RETURN;
            END_IF;

            hasComma := TRUE;
            currentIndex := currentIndex + 1;
            WHILE currentIndex <= patternLength DO
                currentChar := pattern[currentIndex];
                IF currentChar >= '0' AND currentChar <= '9' THEN
                    hasMaxDigit := TRUE;
                    repeatMax := repeatMax * 10 + (TO_INT(TO_BYTE(currentChar)) - 48);
                    currentIndex := currentIndex + 1;
                ELSE
                    EXIT;
                END_IF;
            END_WHILE;

            IF currentIndex > patternLength OR pattern[currentIndex] <> '}' THEN
                RETURN;
            END_IF;

            IF hasComma AND NOT hasMaxDigit THEN
                repeatMax := MAX_REPEAT_COUNT;
            END_IF;

            IF repeatMin > repeatMax THEN
                RETURN;
            END_IF;

            endIndex := currentIndex;
            ParseQuantifier := TRUE;
        END_METHOD

        /// Parses a character class expression and stores its literals and ranges.
        METHOD PRIVATE ParseCharacterClass : BOOL
            VAR_INPUT
                /// Full pattern string.
                pattern : STRING;

                /// Index of the opening [ character.
                startIndex : INT;
            END_VAR
            VAR_IN_OUT
                /// Token instance that receives the parsed character class.
                token : RegexToken;
            END_VAR
            VAR_OUTPUT
                /// Index of the closing ] character.
                endIndex : INT;
            END_VAR
            VAR
                patternLength : INT;
                currentIndex : INT;
                currentChar : CHAR;
                nextChar : CHAR;
                hasContent : BOOL;
            END_VAR

            ParseCharacterClass := FALSE;
            endIndex := 0;
            patternLength := LengthOf(pattern);

            IF pattern[startIndex] <> '[' THEN
                RETURN;
            END_IF;

            token.tokenType := RegexTokenType#CharacterClass;
            token.charClass.isNegated := FALSE;
            token.charClass.literalCount := 0;
            token.charClass.rangeCount := 0;

            currentIndex := startIndex + 1;
            IF currentIndex > patternLength THEN
                RETURN;
            END_IF;

            IF pattern[currentIndex] = '^' THEN
                token.charClass.isNegated := TRUE;
                currentIndex := currentIndex + 1;
            END_IF;

            WHILE currentIndex <= patternLength DO
                currentChar := pattern[currentIndex];

                IF currentChar = ']' THEN
                    IF NOT hasContent THEN
                        RETURN;
                    END_IF;
                    endIndex := currentIndex;
                    ParseCharacterClass := TRUE;
                    RETURN;
                END_IF;

                IF currentChar = CHAR#92 THEN
                    RETURN;
                END_IF;

                IF (currentIndex + 2 <= patternLength) AND (pattern[currentIndex + 1] = '-') AND (pattern[currentIndex + 2] <> ']') THEN
                    nextChar := pattern[currentIndex + 2];
                    IF nextChar = CHAR#92 THEN
                        RETURN;
                    END_IF;
                    IF currentChar > nextChar THEN
                        RETURN;
                    END_IF;
                    IF token.charClass.rangeCount >= 8 THEN
                        RETURN;
                    END_IF;
                    token.charClass.rangeCount := token.charClass.rangeCount + 1;
                    token.charClass.ranges[token.charClass.rangeCount].rangeStart := currentChar;
                    token.charClass.ranges[token.charClass.rangeCount].rangeEnd := nextChar;
                    hasContent := TRUE;
                    currentIndex := currentIndex + 3;
                    CONTINUE;
                END_IF;

                IF token.charClass.literalCount >= 16 THEN
                    RETURN;
                END_IF;
                token.charClass.literalCount := token.charClass.literalCount + 1;
                token.charClass.literals[token.charClass.literalCount] := currentChar;
                hasContent := TRUE;
                currentIndex := currentIndex + 1;
            END_WHILE;
        END_METHOD
    END_CLASS

END_NAMESPACE