import Foundation

public struct URLParser<UserInfo> {
    func parse(_ url: URL, in patternURL: PatternURL, userInfo: UserInfo) -> Context<UserInfo>? {
        guard let scheme = url.scheme, let host = url.host else {
            return nil
        }
        if scheme != patternURL.scheme || patternURL.pathComponents.count != url.pathComponents.count {
            return nil
        }

        var arguments: Arguments = [:]
        if patternURL.host.hasPrefix(PatternURL.keywordPrefix) {
            let keyword = String(patternURL.host[PatternURL.keywordPrefix.endIndex...])
            arguments[keyword] = host
        } else if host != patternURL.host {
            return nil
        }

        for (patternComponent, component) in zip(patternURL.pathComponents, url.pathComponents) {
            if patternComponent.hasPrefix(PatternURL.keywordPrefix) {
                let keyword = String(patternComponent[PatternURL.keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if patternComponent == component {
                continue
            } else {
                return nil
            }
        }
        let parameters: Parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            parameters = components.queryItems ?? []
        } else {
            parameters = []
        }
        return Context<UserInfo>(url: url, arguments: arguments, parameters: parameters, userInfo: userInfo)
    }
}
