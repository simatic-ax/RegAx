USING AxUnit.ResultFunctions;
USING System.Strings;

NAMESPACE AxUnit.Assert

    /// Succeeds when the provided condition is TRUE.
    FUNCTION PUBLIC IsTrue
        VAR_INPUT
            /// Condition that must evaluate to TRUE.
            condition : BOOL;
        END_VAR
        IF condition THEN
            axunit_Succeed();
        ELSE
            axunit_Fail('Condition is not true');
        END_IF;
    END_FUNCTION

    /// Succeeds when the provided condition is FALSE.
    FUNCTION PUBLIC IsFalse
        VAR_INPUT
            /// Condition that must evaluate to FALSE.
            condition : BOOL;
        END_VAR
        IF NOT condition THEN
            axunit_Succeed();
        ELSE
            axunit_Fail('Condition is not false');
        END_IF;
    END_FUNCTION

END_NAMESPACE