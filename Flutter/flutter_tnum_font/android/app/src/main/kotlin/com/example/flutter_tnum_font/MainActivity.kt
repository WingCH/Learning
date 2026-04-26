package com.example.flutter_tnum_font

import android.graphics.Typeface
import android.graphics.fonts.SystemFonts
import android.os.Build
import android.util.Xml
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import org.xmlpull.v1.XmlPullParser

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "flutter_tnum_font/debug",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDebugSnapshot" -> result.success(buildDebugSnapshot(call))
                else -> result.notImplemented()
            }
        }
    }

    private fun buildDebugSnapshot(call: MethodCall): Map<String, Any> {
        val requestedFamily = call.argument<String>("requestedFamily")
        val lookupFamily = requestedFamily ?: DEFAULT_LOOKUP_FAMILY
        val nativeInspection = inspectNativeFontApis(lookupFamily = lookupFamily)
        val configInspections = FONT_CONFIG_LOCATIONS.map { path ->
            inspectFontConfig(path = path, lookupFamily = lookupFamily)
        }

        val readableConfigPaths = configInspections
            .filter { inspection -> inspection.readable }
            .map { inspection -> inspection.path }
            .distinct()

        val candidateFonts = configInspections
            .flatMap { inspection -> inspection.candidateFonts }
            .plus(nativeInspection.candidateFonts)
            .distinct()

        val limitations = buildList {
            addAll(nativeInspection.notes)
            addAll(configInspections.flatMap { inspection -> inspection.notes })
            if (configInspections.none { inspection -> inspection.fileExists }) {
                add("這部裝置找不到已知的 Android 字體 config 檔案。")
            }
            if (readableConfigPaths.isEmpty()) {
                add("找不到可讀取的 Android 字體 config 檔案。")
            }
            if (candidateFonts.isEmpty()) {
                add("找不到可直接對應 `$lookupFamily` 的候選字體。")
            }
        }.distinct()

        return mapOf(
            "manufacturer" to Build.MANUFACTURER.orEmpty(),
            "model" to Build.MODEL.orEmpty(),
            "androidRelease" to Build.VERSION.RELEASE.orEmpty(),
            "sdkInt" to Build.VERSION.SDK_INT,
            "systemCandidates" to candidateFonts,
            "nativeEvidence" to nativeInspection.evidence,
            "readableConfigPaths" to readableConfigPaths,
            "limitations" to limitations,
        )
    }

    private fun inspectNativeFontApis(lookupFamily: String): NativeFontInspection {
        val evidence = mutableListOf<String>()
        val candidateFonts = mutableListOf<String>()
        val notes = mutableListOf<String>()
        var resolvedFamilyName: String? = null

        if (Build.VERSION.SDK_INT >= 34) {
            try {
                resolvedFamilyName = Typeface
                    .create(lookupFamily, Typeface.NORMAL)
                    .systemFontFamilyName

                if (resolvedFamilyName.isNullOrBlank()) {
                    notes.add("Typeface.getSystemFontFamilyName() 未能回傳 system font family。")
                } else {
                    evidence.add("Typeface.getSystemFontFamilyName()：$resolvedFamilyName")
                    candidateFonts.add("Typeface family：$resolvedFamilyName")
                }
            } catch (error: Exception) {
                notes.add("Typeface.getSystemFontFamilyName() 失敗：${error.message ?: "未知錯誤"}")
            }
        } else {
            notes.add("Typeface.getSystemFontFamilyName() 需要 Android 14 / API 34 或以上。")
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                val fontFileNames = SystemFonts.getAvailableFonts()
                    .mapNotNull { font -> font.file?.name }
                    .distinct()
                    .sorted()

                evidence.add("SystemFonts.getAvailableFonts()：${fontFileNames.size} 個 system font files")
            } catch (error: Exception) {
                notes.add("SystemFonts.getAvailableFonts() 失敗：${error.message ?: "未知錯誤"}")
            }
        } else {
            notes.add("SystemFonts.getAvailableFonts() 需要 Android 10 / API 29 或以上。")
        }

        return NativeFontInspection(
            candidateFonts = candidateFonts.distinct(),
            evidence = evidence.distinct(),
            notes = notes.distinct(),
        )
    }

    private fun inspectFontConfig(path: String, lookupFamily: String): FontConfigInspection {
        val file = File(path)
        if (!file.exists()) {
            return FontConfigInspection(
                path = path,
                fileExists = false,
                readable = false,
                candidateFonts = emptyList(),
                notes = emptyList(),
            )
        }

        if (!file.canRead()) {
            return FontConfigInspection(
                path = path,
                fileExists = true,
                readable = false,
                candidateFonts = emptyList(),
                notes = listOf("字體 config 檔案存在但無法讀取：$path"),
            )
        }

        return try {
            val parsedConfig = parseFontConfig(xml = file.readText())
            val resolvedFamily = resolveFamilyName(
                lookupFamily = lookupFamily,
                aliases = parsedConfig.aliases,
            )
            val candidateFonts = parsedConfig.families[resolvedFamily].orEmpty()
            val notes = buildList {
                if (resolvedFamily != lookupFamily) {
                    add("在 $path 內將 alias `$lookupFamily` 解析為 `$resolvedFamily`。")
                }
            }

            FontConfigInspection(
                path = path,
                fileExists = true,
                readable = true,
                candidateFonts = candidateFonts,
                notes = notes,
            )
        } catch (error: Exception) {
            FontConfigInspection(
                path = path,
                fileExists = true,
                readable = false,
                candidateFonts = emptyList(),
                notes = listOf("解析 $path 失敗：${error.message ?: "未知錯誤"}"),
            )
        }
    }

    private fun parseFontConfig(xml: String): ParsedFontConfig {
        val parser = Xml.newPullParser()
        parser.setInput(xml.reader())

        val families = linkedMapOf<String, List<String>>()
        val aliases = linkedMapOf<String, String>()

        var currentFamilyName: String? = null
        val currentFonts = mutableListOf<String>()

        while (parser.eventType != XmlPullParser.END_DOCUMENT) {
            when (parser.eventType) {
                XmlPullParser.START_TAG -> {
                    when (parser.name) {
                        "family" -> {
                            currentFamilyName = parser
                                .getAttributeValue(null, "name")
                                ?.trim()
                                ?.lowercase()
                            currentFonts.clear()
                        }

                        "font" -> {
                            val fontName = parser.readFontFileName()
                            if (currentFamilyName != null && fontName.isNotEmpty()) {
                                currentFonts.add(fontName)
                            }
                        }

                        "alias" -> {
                            val aliasName = parser
                                .getAttributeValue(null, "name")
                                ?.trim()
                                ?.lowercase()
                            val aliasTarget = parser
                                .getAttributeValue(null, "to")
                                ?.trim()
                                ?.lowercase()

                            if (aliasName != null && aliasTarget != null) {
                                aliases[aliasName] = aliasTarget
                            }
                        }
                    }
                }

                XmlPullParser.END_TAG -> {
                    if (parser.name == "family") {
                        if (currentFamilyName != null && currentFonts.isNotEmpty()) {
                            families[currentFamilyName] = currentFonts.distinct()
                        }
                        currentFamilyName = null
                        currentFonts.clear()
                    }
                }
            }

            parser.next()
        }

        return ParsedFontConfig(
            families = families,
            aliases = aliases,
        )
    }

    private fun XmlPullParser.readFontFileName(): String {
        val fontDepth = depth
        val text = StringBuilder()

        while (next() != XmlPullParser.END_DOCUMENT) {
            when (eventType) {
                XmlPullParser.TEXT -> text.append(this.text)
                XmlPullParser.END_TAG -> {
                    if (depth == fontDepth && name == "font") {
                        return text
                            .toString()
                            .trim()
                            .substringAfterLast('/')
                    }
                }
            }
        }

        return text
            .toString()
            .trim()
            .substringAfterLast('/')
    }

    private fun resolveFamilyName(
        lookupFamily: String,
        aliases: Map<String, String>,
    ): String {
        val visited = linkedSetOf<String>()
        var current = lookupFamily.lowercase()

        while (true) {
            if (!visited.add(current)) {
                return current
            }

            val next = aliases[current] ?: return current
            current = next
        }
    }

    private data class ParsedFontConfig(
        val families: Map<String, List<String>>,
        val aliases: Map<String, String>,
    )

    private data class NativeFontInspection(
        val candidateFonts: List<String>,
        val evidence: List<String>,
        val notes: List<String>,
    )

    private data class FontConfigInspection(
        val path: String,
        val fileExists: Boolean,
        val readable: Boolean,
        val candidateFonts: List<String>,
        val notes: List<String>,
    )

    companion object {
        private const val DEFAULT_LOOKUP_FAMILY = "sans-serif"

        private val FONT_CONFIG_LOCATIONS = listOf(
            "/system/etc/fonts.xml",
            "/system_ext/etc/fonts.xml",
            "/product/etc/fonts.xml",
            "/product/etc/fonts_customization.xml",
            "/vendor/etc/fonts.xml",
        )
    }
}
