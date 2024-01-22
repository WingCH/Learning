//
//  ViewController.swift
//  study_encrypt
//
//  Created by Wing CHAN on 11/1/2024.
//

import CryptoSwift
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do {
            let secureDataCoder = SecureDataCoder(name: "a")

            // 假設您想要加密的數據
            let dataToEncrypt = "Hello, World!".data(using: .utf8)!

            print("data: \(dataToEncrypt)")

            // 將數據加密
            let encryptedData = try secureDataCoder.encrypt(data: dataToEncrypt)
            print("Encrypted data: \(encryptedData)")

            // 將數據解密
            let decryptedData = try secureDataCoder.decrypt(data: encryptedData)
            let decryptedString = String(data: decryptedData, encoding: .utf8)!
            print("Decrypted data: \(decryptedString)")
        } catch {
            print("An error occurred: \(error)")
        }
    }
}

public enum SecureDataCoderError: Swift.Error {
    case invalidKey, invalidIV
}

extension String {
    static func generateRandomBytes(length: Int) -> Data? {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        return result == errSecSuccess ? keyData : nil
    }

    static func randomAlphaNum(length: Int) -> String {
        guard let randomData = generateRandomBytes(length: length) else {
            return "" // 或者處理錯誤的情況
        }

        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let lettersCount = UInt32(letters.count)

        return randomData.map { byte in
            let index = Int(byte % UInt8(lettersCount))
            let letterIndex = letters.index(letters.startIndex, offsetBy: index)
            return String(letters[letterIndex])
        }.joined()
    }
}

private class SecureDataCoder {
    private let name: String
    private let keyUserDefaultsKey: String
    private let ivUserDefaultsKey: String

    init(name: String) {
        self.name = name
        self.keyUserDefaultsKey = "\(name)_encryptionKey"
        self.ivUserDefaultsKey = "\(name)_encryptionIV"
    }

    // 獲取AES 256加密鍵
    private func getAES256EncryptionKey() throws -> String {
        if let key = UserDefaults.standard.string(forKey: keyUserDefaultsKey) {
            return key
        } else {
            let newKey = String.randomAlphaNum(length: 32) // 注意：AES-256鍵的長度應該是32位元組
            UserDefaults.standard.set(newKey, forKey: keyUserDefaultsKey)
            return newKey
        }
    }

    // 獲取AES 256加密IV
    private func getAES256EncryptionIV() throws -> String {
        if let iv = UserDefaults.standard.string(forKey: ivUserDefaultsKey) {
            return iv
        } else {
            let newIV = String.randomAlphaNum(length: 16)
            UserDefaults.standard.set(newIV, forKey: ivUserDefaultsKey)
            return newIV
        }
    }

    //

    private func getEncryptor() throws -> AES {
        let key = try getAES256EncryptionKey()
        guard let keyData = key.data(using: .utf8, allowLossyConversion: true) else {
            throw SecureDataCoderError.invalidKey
        }

        let iv = try getAES256EncryptionIV()
        guard let ivData = iv.data(using: .utf8, allowLossyConversion: true) else {
            throw SecureDataCoderError.invalidIV
        }

        // Use pkcs7 padding, which is default
        return try AES(key: keyData.bytes, blockMode: CBC(iv: ivData.bytes))
    }

    func encrypt(data: Data) throws -> Data {
        let encryptedBytes = try getEncryptor().encrypt(data.bytes)
        return Data(encryptedBytes)
    }

    func decrypt(data: Data) throws -> Data {
        let decryptedBytes = try getEncryptor().decrypt(data.bytes)
        return Data(decryptedBytes)
    }
}
