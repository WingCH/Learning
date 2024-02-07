//
//  script.js
//  study_js_interaction
//
//  Created by Wing on 7/2/2024.
//

function getSegments(language, text) {
    const segmenter = new Intl.Segmenter(language, { granularity: 'word' });
    const segments = [];
    const iterator = segmenter.segment(text)[Symbol.iterator]();
    let result = iterator.next();

    while (!result.done) {
        segments.push({
            segment: result.value.segment,
            index: result.value.index,
            input: text,
            isWordLike: result.value.isWordLike
        });
        result = iterator.next();
    }

    return segments;
}
