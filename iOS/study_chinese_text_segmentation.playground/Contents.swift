import NaturalLanguage

//  同NLTokenizer(unit: .word) 效果一樣
//func tokenize(text: String) -> [String] {
//    let tokenize = CFStringTokenizerCreate(kCFAllocatorDefault, text as CFString?, CFRangeMake(0, text.count), kCFStringTokenizerUnitWord, CFLocaleCopyCurrent())
//    CFStringTokenizerAdvanceToNextToken(tokenize)
//    var range = CFStringTokenizerGetCurrentTokenRange(tokenize)
//    var keyWords: [String] = []
//    while range.length > 0 {
//        let wRange = text.index(text.startIndex, offsetBy: range.location) ..< text.index(text.startIndex, offsetBy: range.location + range.length)
//        let keyWord = String(text[wRange])
//        keyWords.append(keyWord)
//        CFStringTokenizerAdvanceToNextToken(tokenize)
//        range = CFStringTokenizerGetCurrentTokenRange(tokenize)
//    }
//    return keyWords
//}


func tokenize2(text: String) -> [String] {
    // 设置分割粒度，.word分词，.paragraph分段落，.sentence分句，document
    let tokenizer = NLTokenizer(unit: .word)
    tokenizer.string = text
    tokenizer.setLanguage(.traditionalChinese)
    var keyWords: [String] = []
    tokenizer.enumerateTokens(in: text.startIndex ..< text.endIndex) { tokenRange, _ in
        keyWords.append(String(text[tokenRange]))
        return true
    }
    return keyWords
}

let text = """
本港與內地早前簽署合作備忘錄推動粵港澳大灣區數據跨境流動。創新科技及工業局局長孫東在一個電台節目說，雖然很多市民可能不完全理解，但形容未來數據就是黃金，這次安排對本港未來發展非常重要，有助促進大灣區高質量發展，特別有利香港建立數據港。

孫東表示，目前國際形勢非常敏感，要確保國家珍貴數據來港後安全，不能流入其他地方，本港一直有非常嚴格的監管，會通過較強的行政手段確保數據安全、有序地運用，兩地正組成聯合工作組，幾個月內會制定具體執行方案，並會簽訂標準合同。

他又表示，本港對於個人數據規管有非常嚴格限制，特別是數據出境方面，因此市民絕對可以放心，而行業之間的重要數據，包括金融、醫療等，亦有法律規管。
"""
//let words = tokenize(text: text)
let words2 = tokenize2(text: text)

//print(words)
print(words2)
