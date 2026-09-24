USING AxUnit.Assert;
USING Simatic.Ax.RegAx;

NAMESPACE RegexTests

    {TestFixture}
    /// Verifies practical regex scenarios using the supported feature subset.
    CLASS TestRegexRealWorldExamples
        VAR
            /// Regex instance reused across real-world example test cases.
            _regex : Regex;
        END_VAR

        {Test}
        /// Ensures a simple department mailbox pattern with fixed local-part length matches.
        METHOD PUBLIC Matches_Corporate_Email_Address
            _regex.SetPattern('^[a-z]{4}@[a-z]{7}\.[a-z]{2}$$');
            _regex.SetInput('team@factory.de');

            IsTrue(_regex.Match());
            Equal(expected := 'team@factory.de', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures the same email pattern rejects addresses without a top-level domain.
        METHOD PUBLIC Rejects_Email_Address_Without_Top_Level_Domain
            _regex.SetPattern('^[\w]+@[\w]+\.[a-z]{2,3}$$');
            _regex.SetInput('john_doe@factory');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures a machine tag with a fixed prefix and four digits is accepted.
        METHOD PUBLIC Matches_Machine_Tag_With_Fixed_Prefix
            _regex.SetPattern('^MCH-\d{4}$$');
            _regex.SetInput('MCH-2048');

            IsTrue(_regex.Match());
            Equal(expected := 'MCH-2048', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures a machine tag is rejected when the numeric part is too short.
        METHOD PUBLIC Rejects_Machine_Tag_When_Digit_Count_Is_Too_Short
            _regex.SetPattern('^MCH-\d{4}$$');
            _regex.SetInput('MCH-248');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures a semantic version string with three numeric blocks matches.
        METHOD PUBLIC Matches_Semantic_Version_String
            _regex.SetPattern('^\d+\.\d+\.\d+$$');
            _regex.SetInput('2.14.7');

            IsTrue(_regex.Match());
            Equal(expected := '2.14.7', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures a semantic version string is rejected when a block is missing.
        METHOD PUBLIC Rejects_Semantic_Version_When_Patch_Block_Is_Missing
            _regex.SetPattern('^\d+\.\d+\.\d+$$');
            _regex.SetInput('2.14');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures a CSV-like sensor record with three numeric fields matches.
        METHOD PUBLIC Matches_Sensor_Record_With_Comma_Separated_Numbers
            _regex.SetPattern('^\d+,\d+,\d+$$');
            _regex.SetInput('120,45,998');

            IsTrue(_regex.Match());
            Equal(expected := '120,45,998', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures a CSV-like sensor record rejects alphabetic noise in a field.
        METHOD PUBLIC Rejects_Sensor_Record_When_Field_Contains_Letters
            _regex.SetPattern('^\d+,\d+,\d+$$');
            _regex.SetInput('120,4A,998');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures a lowercase file name with a three-letter extension matches.
        METHOD PUBLIC Matches_Lowercase_File_Name_With_Extension
            _regex.SetPattern('^[a-z]+\.[a-z]{3}$$');
            _regex.SetInput('report.csv');

            IsTrue(_regex.Match());
            Equal(expected := 'report.csv', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures a file name is rejected when the extension length is wrong.
        METHOD PUBLIC Rejects_File_Name_When_Extension_Length_Is_Wrong
            _regex.SetPattern('^[a-z]+\.[a-z]{3}$$');
            _regex.SetInput('report.xlsx');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures a log level prefix can be found inside a log line.
        METHOD PUBLIC Finds_Log_Level_Inside_Log_Line
            _regex.SetPattern('\[[A-Z]{4,5}\]');
            _regex.SetInput('2026-07-16 [ERROR] Motor overload detected');

            IsTrue(_regex.Match());
            Equal(expected := '[ERROR]', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures a PLC variable name with underscores and digits matches.
        METHOD PUBLIC Matches_Plc_Variable_Name
            _regex.SetPattern('^[A-Za-z_][A-Za-z0-9_]{3,15}$$');
            _regex.SetInput('Motor_01_Run');

            IsTrue(_regex.Match());
            Equal(expected := 'Motor_01_Run', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures a PLC variable name is rejected when it starts with a digit.
        METHOD PUBLIC Rejects_Plc_Variable_Name_Starting_With_Digit
            _regex.SetPattern('^[A-Za-z_][A-Za-z0-9_]{3,15}$$');
            _regex.SetInput('1Motor_Run');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures an HTTP endpoint with a fixed-shape host and numeric port matches.
        METHOD PUBLIC Matches_Http_Url_With_Port
            _regex.SetPattern('^http://plc\d{2}\.local:\d{4}$$');
            _regex.SetInput('http://plc01.local:8080');

            IsTrue(_regex.Match());
            Equal(expected := 'http://plc01.local:8080', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures an HTTP URL is rejected when the port is missing.
        METHOD PUBLIC Rejects_Http_Url_When_Port_Is_Missing
            _regex.SetPattern('^http://[\w]+\.local:\d{4}$$');
            _regex.SetInput('http://plc01.local');

            IsFalse(_regex.Match());
        END_METHOD
    END_CLASS

END_NAMESPACE