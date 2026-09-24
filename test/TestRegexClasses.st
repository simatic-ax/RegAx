USING AxUnit.Assert;
USING Simatic.Ax.RegAx;
NAMESPACE RegexTests
    
    {TestFixture}
    /// Verifies shorthand character classes like \d and \w.
    CLASS TestRegexClasses
        VAR
            /// Regex instance reused across class test cases.
            _regex : Regex;
        END_VAR
        
        {Test}
        /// Ensures one or more digits are matched by \d+.
        METHOD PUBLIC Matches_Digit_Class_With_Plus
            _regex.SetPattern('^\d+$$');
            _regex.SetInput('12345');

            IsTrue(_regex.Match());
            Equal(expected := '12345', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures \d+ rejects inputs containing letters.
        METHOD PUBLIC Rejects_Digit_Class_When_Letters_Appear
            _regex.SetPattern('^\d+$$');
            _regex.SetInput('123a');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures \w works together with a bounded range quantifier.
        METHOD PUBLIC Matches_Word_Class_With_Range_Quantifier
            _regex.SetPattern('^\w{3,5}$$');
            _regex.SetInput('ab_9');

            IsTrue(_regex.Match());
            Equal(expected := 'ab_9', actual := _regex.GetMatch());
        END_METHOD

        {Test}
        /// Ensures \w range quantifiers reject inputs below the minimum length.
        METHOD PUBLIC Rejects_Word_Class_When_Too_Short
            _regex.SetPattern('^\w{3,5}$$');
            _regex.SetInput('ab');

            IsFalse(_regex.Match());
        END_METHOD

        {Test}
        /// Ensures mixed alphabetic ranges like [a-zA-Z] match upper and lower case letters.
        METHOD PUBLIC Matches_Alphabetic_Character_Class_Range
            _regex.SetPattern('^[a-zA-Z]+$$');
            _regex.SetInput('AbCdEf');

            IsTrue(_regex.Match());
            Equal(expected := 'AbCdEf', actual := _regex.GetMatch());
        END_METHOD
    END_CLASS

END_NAMESPACE
