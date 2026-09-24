NAMESPACE Simatic.Ax.RegAx

    /// Token kinds used by the internal regex tokenizer.
    TYPE PUBLIC RegexTokenType : (
        None,
        Literal,
        DigitClass,
        WordClass,
        CharacterClass,
        EscapedLiteral,
        AnchorStart,
        AnchorEnd
    );
    END_TYPE

END_NAMESPACE