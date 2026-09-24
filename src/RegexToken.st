NAMESPACE Simatic.Ax.RegAx

    /// Parsed token with optional quantifier information.
    TYPE PUBLIC RegexToken : STRUCT
        tokenType : RegexTokenType;
        literal : CHAR;
        minCount : INT;
        maxCount : INT;
        charClass : RegexCharClass;
    END_STRUCT;
    END_TYPE

END_NAMESPACE