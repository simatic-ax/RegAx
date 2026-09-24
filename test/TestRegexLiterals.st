USING AxUnit.Assert;
USING Simatic.Ax.RegAx;

NAMESPACE RegexTests

    {TestFixture}
    /// Verifies literal matching behavior for anchored and unanchored patterns.
    CLASS TestRegexLiterals
        VAR
            /// Regex instance reused across literal test cases.
            _regex : Regex;
        END_VAR

        {Test}
        /// Ensures an anchored literal matches the full input.
        METHOD PUBLIC Matches_Exact_Literal_With_Anchors
            _regex.SetPattern('^abc$$');
            _regex.SetInput('abc');

            IsTrue(_regex.Match());
            Equal(expected := 'abc', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures an anchored literal is rejected when the input differs.
        METHOD PUBLIC Rejects_Exact_Literal_When_Input_Differs
            _regex.SetPattern('^abc$$');
            _regex.SetInput('abx');

            IsFalse(_regex.Match());
            Equal(expected := '', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures an unanchored literal can be found inside a larger input.
        METHOD PUBLIC Finds_Unanchored_Literal_Inside_Input
            _regex.SetPattern('abc');
            _regex.SetInput('xxabczz');

            IsTrue(_regex.Match());
            Equal(expected := 'abc', actual := _regex.GetMatch());
        END_METHOD
    END_CLASS

END_NAMESPACE
