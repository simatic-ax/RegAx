USING AxUnit.Assert;
USING Simatic.Ax.RegAx;

NAMESPACE RegexTests

    {TestFixture}
    /// Verifies that unsupported or malformed patterns are rejected safely.
    CLASS TestRegexInvalidPatterns
        VAR
            /// Regex instance reused across invalid-pattern test cases.
            _regex : Regex;
        END_VAR

        {Test}
        /// Ensures unsupported group syntax is rejected.
        METHOD PUBLIC Rejects_Unsupported_Group_Syntax
            _regex.SetPattern('^(ab)$$');
            _regex.SetInput('ab');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures unsupported alternation syntax is rejected.
        METHOD PUBLIC Rejects_Unsupported_Alternation_Syntax
            _regex.SetPattern('^a|b$$');
            _regex.SetInput('a');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures invalid quantifier ranges are rejected.
        METHOD PUBLIC Rejects_Invalid_Quantifier_Range
            _regex.SetPattern('^a{3,2}$$');
            _regex.SetInput('aaa');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures dangling escape sequences are rejected.
        METHOD PUBLIC Rejects_Dangling_Escape
            _regex.SetPattern('abc\');
            _regex.SetInput('abc');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures block-type patterns requiring groups and alternation remain unsupported.
        METHOD PUBLIC Rejects_Block_Type_Pattern_With_Group_And_Alternation
            _regex.SetPattern('(FB|OB|FC)[0-9]{1,5}');
            _regex.SetInput('ADD1@1_FC1.bin');

            IsFalse(_regex.Match());
        END_METHOD
    END_CLASS

END_NAMESPACE