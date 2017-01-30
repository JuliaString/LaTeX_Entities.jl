# Derived from latex_symbols.jl, which is a part of Julia
# License is MIT: http://julialang.org/license

const manual_latex = [
    "cbrt"        => "\u221B", # synonym of \cuberoot
    "mars"        => "♂",      # synonym of \male
    "pprime"      => "″",      # synonym of \dprime
    "ppprime"     => "‴",      # synonym of \trprime
    "pppprime"    => "⁗",      # synonym of \qprime
    "backpprime"  => "‶",      # synonym of \backdprime
    "backppprime" => "‷",      # synonym of \backtrprime
    "emptyset"    => "∅",      # synonym of \varnothing
    "llbracket"   => "⟦",      # synonym of \lBrack
    "rrbracket"   => "⟧",      # synonym of \rBrack
    "xor"         => "⊻",      # synonym of \veebar

    # Misc. Math and Physics
    "del"         => "∇",      # synonym of \nabla (combining character)
    "sout"        => "\u0336", # synonym of \Elzbar (from ulem package)

    # Avoid getting "incorrect" synonym
    "imath"       => "\U1d6a4",     # 𝚤
    "hbar"        => "\u0127",      # ħ synonym of \Elzxh
    "AA"          => "\u00c5",      # Å
    "Upsilon"     => "\u03a5",      # Υ
    "setminus"    => "\u2216",      # ∖ synonym of \smallsetminus
    "circlearrowleft"  => "\u21ba", # ↺ synonym of acwopencirclearrow
    "circlearrowright" => "\u21bb", # ↻ synonym of cwopencirclearrow
    # "bigsetminus" => "\u29f5",  # add to allow access to standard setminus

    # Vulgar fractions
    "1/4"  => "¼", # vulgar fraction one quarter
    "1/2"  => "½", # vulgar fraction one half
    "3/4"  => "¾", # vulgar fraction three quarters
    "1/7"  => "⅐",# vulgar fraction one seventh
    "1/9"  => "⅑", # vulgar fraction one ninth
    "1/10" => "⅒", # vulgar fraction one tenth
    "1/3"  => "⅓", # vulgar fraction one third
    "2/3"  => "⅔", # vulgar fraction two thirds
    "1/5"  => "⅕", # vulgar fraction one fifth
    "2/5"  => "⅖", # vulgar fraction two fifths
    "3/5"  => "⅗", # vulgar fraction three fifths
    "4/5"  => "⅘", # vulgar fraction four fifths
    "1/6"  => "⅙", # vulgar fraction one sixth
    "5/6"  => "⅚", # vulgar fraction five sixths
    "1/8"  => "⅛", # vulgar fraction one eigth
    "3/8"  => "⅜", # vulgar fraction three eigths
    "5/8"  => "⅝", # vulgar fraction five eigths
    "7/8"  => "⅞", # vulgar fraction seventh eigths
    "1/"   => "⅟", # fraction numerator one
    "0/3"  => "↉", # vulgar fraction zero thirds
    "1/4"  => "¼", # vulgar fraction one quarter

    # Superscripts
    "^0" => "⁰",
    "^1" => "¹",
    "^2" => "²",
    "^3" => "³",
    "^4" => "⁴",
    "^5" => "⁵",
    "^6" => "⁶",
    "^7" => "⁷",
    "^8" => "⁸",
    "^9" => "⁹",
    "^+" => "⁺",
    "^-" => "⁻",
    "^=" => "⁼",
    "^(" => "⁽",
    "^)" => "⁾",
    "^a" => "ᵃ",
    "^b" => "ᵇ",
    "^c" => "ᶜ",
    "^d" => "ᵈ",
    "^e" => "ᵉ",
    "^f" => "ᶠ",
    "^g" => "ᵍ",
    "^h" => "ʰ",
    "^i" => "ⁱ",
    "^j" => "ʲ",
    "^k" => "ᵏ",
    "^l" => "ˡ",
    "^m" => "ᵐ",
    "^n" => "ⁿ",
    "^o" => "ᵒ",
    "^p" => "ᵖ",
    "^r" => "ʳ",
    "^s" => "ˢ",
    "^t" => "ᵗ",
    "^u" => "ᵘ",
    "^v" => "ᵛ",
    "^w" => "ʷ",
    "^x" => "ˣ",
    "^y" => "ʸ",
    "^z" => "ᶻ",
    "^A" => "ᴬ",
    "^B" => "ᴮ",
    "^D" => "ᴰ",
    "^E" => "ᴱ",
    "^G" => "ᴳ",
    "^H" => "ᴴ",
    "^I" => "ᴵ",
    "^J" => "ᴶ",
    "^K" => "ᴷ",
    "^L" => "ᴸ",
    "^M" => "ᴹ",
    "^N" => "ᴺ",
    "^O" => "ᴼ",
    "^P" => "ᴾ",
    "^R" => "ᴿ",
    "^T" => "ᵀ",
    "^U" => "ᵁ",
    "^V" => "ⱽ",
    "^W" => "ᵂ",
    "^alpha" => "ᵅ",
    "^beta" => "ᵝ",
    "^gamma" => "ᵞ",
    "^delta" => "ᵟ",
    "^epsilon" => "ᵋ",
    "^theta" => "ᶿ",
    "^iota" => "ᶥ",
    "^phi" => "ᵠ",
    "^chi" => "ᵡ",
    "^Phi" => "ᶲ",

    # Subscripts
    "_0" => "₀",
    "_1" => "₁",
    "_2" => "₂",
    "_3" => "₃",
    "_4" => "₄",
    "_5" => "₅",
    "_6" => "₆",
    "_7" => "₇",
    "_8" => "₈",
    "_9" => "₉",
    "_+" => "₊",
    "_-" => "₋",
    "_=" => "₌",
    "_(" => "₍",
    "_)" => "₎",
    "_a" => "ₐ",
    "_e" => "ₑ",
    "_h" => "ₕ",
    "_i" => "ᵢ",
    "_j" => "ⱼ",
    "_k" => "ₖ",
    "_l" => "ₗ",
    "_m" => "ₘ",
    "_n" => "ₙ",
    "_o" => "ₒ",
    "_p" => "ₚ",
    "_r" => "ᵣ",
    "_s" => "ₛ",
    "_t" => "ₜ",
    "_u" => "ᵤ",
    "_v" => "ᵥ",
    "_x" => "ₓ",
    "_schwa" => "ₔ",
    "_beta" => "ᵦ",
    "_gamma" => "ᵧ",
    "_rho" => "ᵨ",
    "_phi" => "ᵩ",
    "_chi" => "ᵪ"
]
