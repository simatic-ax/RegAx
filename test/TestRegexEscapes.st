USING AxUnit.Assert;
USING Simatic.Ax.RegAx;
USING System.Strings;
NAMESPACE RegexTests

    {TestFixture}
    /// Verifies escaped literals and IP-like matching scenarios.
    CLASS TestRegexEscapes
        VAR
            /// Regex instance reused across escape and IP test cases.
            _regex : Regex;
        END_VAR

        /// Returns the substring after the first occurrence of a separator.
        METHOD PRIVATE TailAfterFirstSeparator : STRING
            VAR_INPUT
                input : STRING;
                separator : CHAR;
            END_VAR
            VAR
                currentIndex : INT;
                inputLength : INT;
                result : STRING;
                separatorFound : BOOL;
            END_VAR

            result := '';
            inputLength := LengthOf(input);
            separatorFound := FALSE;

            FOR currentIndex := 1 TO inputLength DO
                IF separatorFound THEN
                    result := CONCAT(result, input[currentIndex]);
                ELSIF input[currentIndex] = separator THEN
                    separatorFound := TRUE;
                END_IF;
            END_FOR;

            TailAfterFirstSeparator := result;
        END_METHOD

        {Test}
        /// Ensures an escaped dot is treated as a literal dot.
        METHOD PUBLIC Matches_Escaped_Dot
            _regex.SetPattern('^\.$$');
            _regex.SetInput('.');

            IsTrue(_regex.Match());
            Equal(expected := '.', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures a simple dotted digit pattern matches a typical IP-like string.
        METHOD PUBLIC Matches_Simple_Ip_Like_Pattern
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('192.168.0.1');

            IsTrue(_regex.Match());
            Equal(expected := '192.168.0.1', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures the same IP-like pattern accepts minimum-width blocks.
        METHOD PUBLIC Matches_Simple_Ip_Like_Pattern_With_Min_Values
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('0.0.0.0');

            IsTrue(_regex.Match());
            Equal(expected := '0.0.0.0', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures the same IP-like pattern accepts maximum-width blocks.
        METHOD PUBLIC Matches_Simple_Ip_Like_Pattern_With_Max_Width_Blocks
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('255.255.255.255');

            IsTrue(_regex.Match());
            Equal(expected := '255.255.255.255', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures the regex checks structure only and not numeric IPv4 ranges.
        METHOD PUBLIC Matches_Simple_Ip_Like_Pattern_Even_When_Block_Value_Exceeds_Ipv4_Range
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('999.999.999.999');

            IsTrue(_regex.Match());
            Equal(expected := '999.999.999.999', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures an unanchored IP-like pattern extracts only the IP part from a URL.
        METHOD PUBLIC Finds_Ip_Address_Inside_Url_And_Returns_Only_The_Ip
            _regex.SetPattern('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
            _regex.SetInput('http://192.168.0.1');

            IsTrue(_regex.Match());
            Equal(expected := '192.168.0.1', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures an unanchored IP-like pattern extracts only the IP part from an HTTPS URL with a port.
        METHOD PUBLIC Finds_Ip_Address_Inside_Https_Url_With_Port_And_Returns_Only_The_Ip
            _regex.SetPattern('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
            _regex.SetInput('https://192.168.0.1:5050');

            IsTrue(_regex.Match());
            Equal(expected := '192.168.0.1', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Demonstrates manual iteration over successive IP blocks by advancing the remaining input.
        METHOD PUBLIC Finds_All_Ip_Blocks_By_Repeating_Single_Block_Match_On_Remaining_Input
            VAR
                remainingInput : STRING;
            END_VAR

            _regex.SetPattern('\d{1,3}');

            remainingInput := 'https://192.168.0.1';
            _regex.SetInput(remainingInput);
            IsTrue(_regex.Match());
            Equal(expected := '192', actual := _regex.GetMatch());

            remainingInput := THIS.TailAfterFirstSeparator(input := remainingInput, separator := '.');
            _regex.SetInput(remainingInput);
            IsTrue(_regex.Match());
            Equal(expected := '168', actual := _regex.GetMatch());

            remainingInput := THIS.TailAfterFirstSeparator(input := remainingInput, separator := '.');
            _regex.SetInput(remainingInput);
            IsTrue(_regex.Match());
            Equal(expected := '0', actual := _regex.GetMatch());

            remainingInput := THIS.TailAfterFirstSeparator(input := remainingInput, separator := '.');
            _regex.SetInput(remainingInput);
            IsTrue(_regex.Match());
            Equal(expected := '1', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures MatchNext can iterate over all IP blocks without modifying the input string.
        METHOD PUBLIC Finds_All_Ip_Blocks_With_MatchNext
            _regex.SetPattern('\d{1,3}');
            _regex.SetInput('https://192.168.0.1');

            IsTrue(_regex.Match());
            Equal(expected := '192', actual := _regex.GetMatch());

            IsTrue(_regex.MatchNext());
            Equal(expected := '168', actual := _regex.GetMatch());

            IsTrue(_regex.MatchNext());
            Equal(expected := '0', actual := _regex.GetMatch());

            IsTrue(_regex.MatchNext());
            Equal(expected := '1', actual := _regex.GetMatch());

            IsFalse(_regex.MatchNext());
        END_METHOD

        {Test}
        /// Ensures MatchNext reports the positions of successive matches.
        METHOD PUBLIC Reports_Start_And_End_Index_For_Successive_MatchNext_Calls
            _regex.SetPattern('\d{1,3}');
            _regex.SetInput('https://192.168.0.1');

            IsTrue(_regex.Match());
            Equal(expected := '192', actual := _regex.GetMatch());
            Equal(expected := 9, actual := _regex.GetMatchStartIndex());
            Equal(expected := 11, actual := _regex.GetMatchEndIndex());

            IsTrue(_regex.MatchNext());
            Equal(expected := '168', actual := _regex.GetMatch());
            Equal(expected := 13, actual := _regex.GetMatchStartIndex());
            Equal(expected := 15, actual := _regex.GetMatchEndIndex());
        END_METHOD

        {Test}
        /// Ensures the IP-like pattern rejects inputs with a missing final block.
        METHOD PUBLIC Rejects_Simple_Ip_Like_Pattern_When_Last_Block_Missing
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('192.168.0');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures the IP-like pattern rejects blocks longer than three digits.
        METHOD PUBLIC Rejects_Simple_Ip_Like_Pattern_When_Block_Is_Too_Long
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('1234.168.0.1');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures the IP-like pattern rejects non-digit characters inside a block.
        METHOD PUBLIC Rejects_Simple_Ip_Like_Pattern_When_Non_Digit_Appears_In_Block
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('192.16a.0.1');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures the IP-like pattern rejects wrong separators.
        METHOD PUBLIC Rejects_Simple_Ip_Like_Pattern_When_Separator_Is_Wrong
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('192,168.0.1');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures the IP-like pattern rejects trailing whitespace when anchored.
        METHOD PUBLIC Rejects_Simple_Ip_Like_Pattern_When_Whitespace_Is_Present
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('192.168.0.1 ');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures the IP-like pattern rejects a leading separator.
        METHOD PUBLIC Rejects_Simple_Ip_Like_Pattern_When_Leading_Dot_Is_Present
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('.192.168.0.1');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures the IP-like pattern rejects a trailing separator.
        METHOD PUBLIC Rejects_Simple_Ip_Like_Pattern_When_Trailing_Dot_Is_Present
            _regex.SetPattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$$');
            _regex.SetInput('192.168.0.1.');

            IsFalse(_regex.Match());
        END_METHOD
    END_CLASS

END_NAMESPACE
