// SHA-1 implementation in Swift 4
// $AUTHOR: Iggy Drougge
// $VER: 2.3.1
import Foundation

infix operator <<< : BitwiseShiftPrecedence
private func <<< (lhs: UInt32, rhs: UInt32) -> UInt32 {
    return lhs << rhs | lhs >> (32 - rhs)
}

public struct SHA1 {
    private static let CHUNKSIZE = 80
    private static let h0: UInt32 = 0x67452301
    private static let h1: UInt32 = 0xEFCDAB89
    private static let h2: UInt32 = 0x98BADCFE
    private static let h3: UInt32 = 0x10325476
    private static let h4: UInt32 = 0xC3D2E1F0

    private struct Context {
        // Initialise variables:
        var h: [UInt32] = [SHA1.h0, SHA1.h1, SHA1.h2, SHA1.h3, SHA1.h4]

        // Process one chunk of 80 big-endian longwords
        mutating func process(chunk: inout ContiguousArray<UInt32>) {
            for i in 0..<16 {
                chunk[i] = chunk[i].bigEndian
            }
            for i in 16...79 {
                chunk[i] = (chunk[i-3] ^ chunk[i-8] ^ chunk[i-14] ^ chunk[i-16]) <<< 1
            }
            // Initialise hash value for this chunk:
            var a, b, c, d, e, f, k, temp: UInt32
            a = h[0]; b = h[1]; c = h[2]; d = h[3]; e = h[4]
            f = 0x0; k = 0x0

            // Main loop
            for i in 0...79 {
                switch i {
                case 0...19:
                    f = (b & c) | ((~b) & d)
                    k = 0x5A827999
                case 20...39:
                    f = b ^ c ^ d
                    k = 0x6ED9EBA1
                case 40...59:
                    f = (b & c) | (b & d) | (c & d)
                    k = 0x8F1BBCDC
                case 60...79:
                    f = b ^ c ^ d
                    k = 0xCA62C1D6
                default: break
                }
                temp = a <<< 5 &+ f &+ e &+ k &+ chunk[i]
                e = d
                d = c
                c = b <<< 30
                b = a
                a = temp
            }
            h[0] = h[0] &+ a
            h[1] = h[1] &+ b
            h[2] = h[2] &+ c
            h[3] = h[3] &+ d
            h[4] = h[4] &+ e
        }
    }
    private static func process(data: inout Data) -> SHA1.Context? {
        var context = SHA1.Context()
        var w = ContiguousArray<UInt32>(repeating: 0x00000000, count: CHUNKSIZE)
        let ml = data.count << 3
        var range = 0..<64
        while data.count >= range.upperBound {
            w.withUnsafeMutableBufferPointer { dest in
                data.copyBytes(to: dest, from: range)
            }
            context.process(chunk: &w)
            range = range.upperBound..<range.upperBound + 64
        }
        w = ContiguousArray<UInt32>(repeating: 0x00000000, count: CHUNKSIZE)
        range = range.lowerBound..<data.count
        w.withUnsafeMutableBufferPointer { dest in
            data.copyBytes(to: dest, from: range)
        }
        let bytetochange=range.count % 4
        let shift = UInt32(bytetochange * 8)
        w[range.count / 4] |= 0x80 << shift
        if range.count + 1 > 56 {
            context.process(chunk: &w)
            w = ContiguousArray<UInt32>(repeating: 0x00000000, count: CHUNKSIZE)
        }
        w[15] = UInt32(ml).bigEndian
        context.process(chunk: &w)
        return context
    }
    private static func hexString(_ context: SHA1.Context?) -> String? {
        guard let c=context else {return nil}
        return String(format: "%08X %08X %08X %08X %08X", c.h[0], c.h[1], c.h[2], c.h[3], c.h[4])
    }
    private static func dataFromFile(named filename: String) -> SHA1.Context? {
        guard var file = try? Data(contentsOf: URL(fileURLWithPath: filename)) else {return nil}
        return process(data: &file)
    }
    static public func hexString(fromFile filename: String) -> String? {
        return hexString(SHA1.dataFromFile(named: filename))
    }
    public static func hash(fromFile filename: String) -> [Int]? {
        return dataFromFile(named: filename)?.h.map { Int($0) }
    }
    public static func hexString(from data: inout Data) -> String? {
        return hexString(SHA1.process(data: &data))
    }
    public static func hash(from data: inout Data) -> [Int]? {
        return process(data: &data)?.h.map { Int($0) }
    }
    public static func hexString(from str: String) -> String? {
        guard var data = str.data(using: .utf8) else { return nil }
        return hexString(SHA1.process(data: &data))
    }
    public static func hash(from str: String) -> [Int]? {
        guard var data = str.data(using: .utf8) else { return nil }
        return process(data: &data)?.h.map { Int($0) }
    }
}
