import NaturalLanguage

//  同NLTokenizer(unit: .word) 效果一樣
func tokenize(text: String) -> [String] {
    let tokenize = CFStringTokenizerCreate(kCFAllocatorDefault, text as CFString?, CFRangeMake(0, text.count), kCFStringTokenizerUnitWord, CFLocaleCopyCurrent())
    CFStringTokenizerAdvanceToNextToken(tokenize)
    var range = CFStringTokenizerGetCurrentTokenRange(tokenize)
    var keyWords: [String] = []
    while range.length > 0 {
        let wRange = text.index(text.startIndex, offsetBy: range.location) ..< text.index(text.startIndex, offsetBy: range.location + range.length)
        let keyWord = String(text[wRange])
        keyWords.append(keyWord)
        CFStringTokenizerAdvanceToNextToken(tokenize)
        range = CFStringTokenizerGetCurrentTokenRange(tokenize)
    }
    return keyWords
}


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

var text = """
19分鐘前 •查看翻譯
"""
/*
 要實現在分詞前刪除所有符號，只保留空格、文字和數字，你可以在 tokenize 函數中加入一個步驟來處理這個需求。以下是修改後的 tokenize 函數，它首先使用正則表達式移除非文字、非數字和非空格的字符，然後再進行分詞：
 */
text = text.replacingOccurrences(of: "[^\\w\\s]", with: "", options: .regularExpression)

let words = tokenize(text: text)
let words2 = tokenize2(text: text)

print(words)
print(words2)
