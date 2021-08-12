//
//  URLParser.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Foundation

protocol TokenURIParseable {
    func parseTokenURI(_ url: URL) -> URL
}

protocol MediaURLParseable {
    func parseMediaURLString(_ urlString: String) -> URL?
}

// TODO: Refactor
final class URLParser: TokenURIParseable, MediaURLParseable {
    
    func parseTokenURI(_ url: URL) -> URL {
        var url = url
        // Should probably route all urls to gateways
        // e.g. https://gateway.pinata.cloud/ipfs/QmZuKciW2Amabd8aZDKEXawTEJFDeNbtjtN5B4swMtcqTK
        // too many requests error
        
        // once received only QmWXENbdrQBcEXtyfAtZfWJDpn3e3Kzz4d4SpiBDQtS5Kp as url
        // --> need to check if valid ipfs hash https://github.com/ipfs-shipyard/is-ipfs/blob/master/src/index.js
        if url.host == "ipfs", let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
            url = cloudflareURL.appendingPathComponent(url.path)
        } else if url.scheme == "ipfs", let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
            // ipfs://QmZANhgW1EaNz8CKN22uHrUpL62xcJEs3iawjYzACCmVsc/3
            url = cloudflareURL
                .appendingPathComponent(url.host ?? "")
                .appendingPathComponent(url.path)
        }
        return url
    }
    
    func parseMediaURLString(_ urlString: String) -> URL? {
        guard var url = URL(string: urlString) else { return nil }
        if url.host?.contains("ipfs") ?? false, let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
            let path = url.path.replacingOccurrences(of: "/ipfs", with: "")
            url = cloudflareURL.appendingPathComponent(path)
        } else if url.scheme == "ipfs", let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
            // ipfs://QmZANhgW1EaNz8CKN22uHrUpL62xcJEs3iawjYzACCmVsc/3
            url = cloudflareURL
                .appendingPathComponent(url.host ?? "")
                .appendingPathComponent(url.path)
        }
        return url
    }
}


// on cloudfare sometimes get: video streaming is not allowed
//—> support different gateways

//export default helper(function hitUrls([hit]/*, hash*/) {
//  return [
//    `https://gateway.ipfs.io/ipfs/${hit.hash}`,
//    `https://clowdflare-ipfs.com/ipfs/${hit.hash}`
//  ];
//});
