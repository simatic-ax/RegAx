USING AxUnit.Assert;
USING Simatic.Ax.RegAx;

NAMESPACE RegexTests

    {TestFixture}
    /// Verifies supported quantifiers like ?, *, and bounded repetitions.
    CLASS TestRegexQuantifiers
        VAR
            /// Regex instance reused across quantifier test cases.
            _regex : Regex;
        END_VAR

        {Test}
        /// Ensures an optional literal matches when the optional character is present.
        METHOD PUBLIC Matches_Optional_Literal_When_Present
            _regex.SetPattern('^colou?r$$');
            _regex.SetInput('colour');

            IsTrue(_regex.Match());
            Equal(expected := 'colour', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures an optional literal matches when the optional character is absent.
        METHOD PUBLIC Matches_Optional_Literal_When_Absent
            _regex.SetPattern('^colou?r$$');
            _regex.SetInput('color');

            IsTrue(_regex.Match());
            Equal(expected := 'color', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures exact repetition counts are accepted when the count matches.
        METHOD PUBLIC Matches_Exact_Repetition
            _regex.SetPattern('^a{3}$$');
            _regex.SetInput('aaa');

            IsTrue(_regex.Match());
            Equal(expected := 'aaa', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures exact repetition counts reject shorter inputs.
        METHOD PUBLIC Rejects_Exact_Repetition_When_Count_Differs
            _regex.SetPattern('^a{3}$$');
            _regex.SetInput('aa');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures open upper bound quantifiers accept longer runs.
        METHOD PUBLIC Matches_Open_Upper_Bound_Quantifier
            _regex.SetPattern('^a{2,}$$');
            _regex.SetInput('aaaa');

            IsTrue(_regex.Match());
            Equal(expected := 'aaaa', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures the star quantifier accepts repeated middle literals.
        METHOD PUBLIC Matches_Star_Quantifier
            _regex.SetPattern('^ab*c$$');
            _regex.SetInput('abbbc');

            IsTrue(_regex.Match());
            Equal(expected := 'abbbc', actual := _regex.GetMatch());
        END_METHOD
    END_CLASS

END_NAMESPACE
