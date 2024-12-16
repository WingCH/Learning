from markitdown import MarkItDown

markitdown = MarkItDown()
result = markitdown.convert('微软开源MarkItDown项目 支持将PDF_办公文档_图片_音视频转换为Markdown格式 – 蓝点网.html')
print(result.text_content)
