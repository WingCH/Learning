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
港女食 Five Guys 叫芝士漢堡包走包 結果冬天嘅瑞士係咪無咁值唔值得去
"""
//let words = tokenize(text: text)
let words2 = tokenize2(text: text)

//print(words)
print(words2)
