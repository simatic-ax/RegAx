NAMESPACE Simatic.Ax.RegAx

    /// Parsed representation of a character class like [abc], [a-z] or [^abc].
    TYPE INTERNAL RegexCharClass : STRUCT
        isNegated : BOOL;
        literalCount : INT;
        literals : ARRAY[1..16] OF CHAR;
        rangeCount : INT;
        ranges : ARRAY[1..8] OF RegexCharClassRange;
    END_STRUCT;
    END_TYPE

END_NAMESPACE