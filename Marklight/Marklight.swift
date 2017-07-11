//    Marklight
//    Copyright (c) 2016 Matteo Gavagnin
//
//    Permission is hereby granted, free of charge, to any person obtaining
//    a copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//    permit persons to whom the Software is furnished to do so, subject to
//    the following conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//    ------------------------------------------------------------------------------
//
//    Markdown.swift
//    Copyright (c) 2014 Kristopher Johnson
//
//    Permission is hereby granted, free of charge, to any person obtaining
//    a copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//    permit persons to whom the Software is furnished to do so, subject to
//    the following conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//    Markdown.swift is based on MarkdownSharp, whose licenses and history are
//    enumerated in the following sections.
//
//    ------------------------------------------------------------------------------
//
//    MarkdownSharp
//    -------------
//    a C# Markdown processor
//
//    Markdown is a text-to-HTML conversion tool for web writers
//    Copyright (c) 2004 John Gruber
//    http://daringfireball.net/projects/markdown/
//
//    Markdown.NET
//    Copyright (c) 2004-2009 Milan Negovan
//    http://www.aspnetresources.com
//    http://aspnetresources.com/blog/markdown_announced.aspx
//
//    MarkdownSharp
//    Copyright (c) 2009-2011 Jeff Atwood
//    http://stackoverflow.com
//    http://www.codinghorror.com/blog/
//    http://code.google.com/p/markdownsharp/
//
//    History: Milan ported the Markdown processor to C#. He granted license to me so I can open source it
//    and let the community contribute to and improve MarkdownSharp.
//
//    ------------------------------------------------------------------------------
//
//    Copyright (c) 2009 - 2010 Jeff Atwood
//
//    http://www.opensource.org/licenses/mit-license.php
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.
//
//    ------------------------------------------------------------------------------
//
//    Copyright (c) 2003-2004 John Gruber
//    <http://daringfireball.net/>
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are
//    met:
//
//    Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//    Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
//    Neither the name "Markdown" nor the names of its contributors may
//    be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
//    This software is provided by the copyright holders and contributors "as
//    is" and any express or implied warranties, including, but not limited
//    to, the implied warranties of merchantability and fitness for a
//    particular purpose are disclaimed. In no event shall the copyright owner
//    or contributors be liable for any direct, indirect, incidental, special,
//    exemplary, or consequential damages (including, but not limited to,
//    procurement of substitute goods or services; loss of use, data, or
//    profits; or business interruption) however caused and on any theory of
//    liability, whether in contract, strict liability, or tort (including
//    negligence or otherwise) arising in any way out of the use of this
//    software, even if advised of the possibility of such damage.

import Foundation
import UIKit

// Wrapper for NSRegularExpression.
//
public struct Regex {
    
    fileprivate let regularExpression: NSRegularExpression!
    
    fileprivate init(pattern: String, options: NSRegularExpression.Options = NSRegularExpression.Options(rawValue: 0)) {
        var error: NSError?
        let re: NSRegularExpression?
        
        do {
            re = try NSRegularExpression(pattern: pattern, options: options)
        }
        catch let error1 as NSError {
            error = error1
            re = nil
        }
        
        // If re is nil, it means NSRegularExpression didn't like
        // the pattern we gave it.  All regex patterns used by Markdown
        // should be valid, so this probably means that a pattern
        // valid for .NET Regex is not valid for NSRegularExpression.
        if re == nil {
            if let error = error {
                print("Regular expression error: \(error.userInfo)")
            }
            assert(re != nil)
        }
        
        self.regularExpression = re
    }
    
    fileprivate func matches(_ input: String, range: NSRange, completion: @escaping (_ result: NSTextCheckingResult?) -> Void) {
        let s = input as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        regularExpression.enumerateMatches(in: s as String,
                                           options: options,
                                           range: range,
                                           using: { (result, flags, stop) -> Void in
                                            completion(result)
        })
    }
}


// MarklightStyler provides markdown processing for a particular
// Regex object.
//
public protocol MarklightStyler {
    var matcher: Regex { get }
    func processMatch(in string: NSMutableAttributedString, range: NSRange)
}


// A simple markdown styler: parses an input string with the Regex and applies
// the given styling attributes.
//
open class BasicStyler: MarklightStyler {
    
    public let matcher: Regex
    public let attributes: [String: AnyObject]
    
    init(matcher: Regex, attributes: [String: AnyObject]) {
        self.matcher = matcher
        self.attributes = attributes
    }
    
    public func processMatch(in string: NSMutableAttributedString, range: NSRange) {
        
        matcher.matches(string.string, range: range) { (result) in
            string.addAttributes(self.attributes, range: result!.range)

        }
    }
}


// Called within processMatch
public typealias StylingCallback = (NSMutableAttributedString, NSRange) -> Void


// Parses input string with given Regex and calls the callback closure
// to apply the styling.
//
open class CallbackStyler: MarklightStyler {
    
    public let matcher: Regex
    public let styling: StylingCallback

    init(matcher: Regex, styling: @escaping StylingCallback) {
        self.matcher = matcher
        self.styling = styling
    }
    
    public func processMatch(in string: NSMutableAttributedString, range: NSRange) {
        matcher.matches(string.string, range: range) { (result) in
            self.styling(string, result!.range)
        }
    }
}

// Defines the styling attributes
//
open class MarklightStyle: NSObject {
    /**
     `UIColor` used to highlight markdown syntax. Default value is light grey.
     */
    public var syntaxColor = UIColor.lightGray
    
    /**
     Font used for blocks and inline code. Default value is *Menlo*.
     */
    public var codeFontName = "Menlo"
    
    /**
     `UIColor` used for blocks and inline code. Default value is dark grey.
     */
    public var codeColor = UIColor.darkGray
    
    /**
     Font used for quote blocks. Default value is *Menlo*.
     */
    public var quoteFontName = "Menlo"
    
    /**
     `UIColor` used for quote blocks. Default value is dark grey.
     */
    public var quoteColor = UIColor.darkGray
    
    /**
     Quote indentation in points. Default 20.
     */
    public var quoteIndendation : CGFloat = 20
    
    /**
     Dynamic type font text style, default `UIFontTextStyleBody`.
     
     - see:
     [Text
     Styles](xcdoc://?url=developer.apple.com/library/ios/documentation/UIKit/Reference/UIFontDescriptor_Class/index.html#//apple_ref/doc/constant_group/Text_Styles)
     */
    public var fontTextStyle : String = UIFontTextStyle.body.rawValue
    
    /**
     If the markdown syntax should be hidden or visible
     */
    public var hideSyntax = false
    
    // We are validating the user provided fontTextStyle `String` to match the
    // system supported ones.
    fileprivate var fontTextStyleValidated : String {
        if fontTextStyle == UIFontTextStyle.headline.rawValue {
            return UIFontTextStyle.headline.rawValue
        } else if fontTextStyle == UIFontTextStyle.subheadline.rawValue {
            return UIFontTextStyle.subheadline.rawValue
        } else if fontTextStyle == UIFontTextStyle.body.rawValue {
            return UIFontTextStyle.body.rawValue
        } else if fontTextStyle == UIFontTextStyle.footnote.rawValue {
            return UIFontTextStyle.footnote.rawValue
        } else if fontTextStyle == UIFontTextStyle.caption1.rawValue {
            return UIFontTextStyle.caption1.rawValue
        } else if fontTextStyle == UIFontTextStyle.caption2.rawValue {
            return UIFontTextStyle.caption2.rawValue
        }
        
        if #available(iOS 9.0, *) {
            if fontTextStyle == UIFontTextStyle.title1.rawValue {
                return UIFontTextStyle.title1.rawValue
            } else if fontTextStyle == UIFontTextStyle.title2.rawValue {
                return UIFontTextStyle.title2.rawValue
            } else if fontTextStyle == UIFontTextStyle.title3.rawValue {
                return UIFontTextStyle.title3.rawValue
            } else if fontTextStyle == UIFontTextStyle.callout.rawValue {
                return UIFontTextStyle.callout.rawValue
            }
        }
        return UIFontTextStyle.body.rawValue
    }
    
    public init(hideSyntax: Bool) {
        self.hideSyntax = hideSyntax
    }
    
    // We transform the user provided `codeFontName` `String` to a `NSFont`
    fileprivate func codeFont(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: codeFontName, size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    // We transform the user provided `quoteFontName` `String` to a `NSFont`
    fileprivate func quoteFont(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: quoteFontName, size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    // Transform the quote indentation in the `NSParagraphStyle` required to set
    //  the attribute on the `NSAttributedString`.
    fileprivate var quoteIndendationStyle : NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = quoteIndendation
        return paragraphStyle
    }
}


// Define default stylers
//
extension MarklightStyle {
    
    func defaultStylers() -> [MarklightStyler] {
        
        let textSize = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle(rawValue: fontTextStyleValidated)).pointSize
        
        let h1HeadingFont = UIFont.boldSystemFont(ofSize: 25.0)
        let h2HeadingFont = UIFont.boldSystemFont(ofSize: 20.0)
        let h3HeadingFont = UIFont.boldSystemFont(ofSize: 15.0)
        
        let italicFont = UIFont.italicSystemFont(ofSize: textSize)
        let boldFont = UIFont.boldSystemFont(ofSize: textSize)
        let codeFont = self.codeFont(textSize)
        let quoteFont = self.quoteFont(textSize)
        
        let hiddenAttributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 0.1),
            NSForegroundColorAttributeName: UIColor.clear
        ]
        
        var result: [MarklightStyler] = []
        

        // MARK: HEADERS
        // -------------
        
        // Hash headers: 1 to 6 #'s followed by text
        //
        let headerMatcher = CallbackStyler(matcher: MarklightStyle.headersAtxRegex) { (attrStr, matchRange) in
            
            MarklightStyle.headersAtxOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                
                // num #'s determines header size ($1 = #{1,6})
                let font: UIFont;
                let numHashes = innerResult!.rangeAt(1).length
                
                switch numHashes {
                case 1: font = h1HeadingFont;
                case 2: font = h2HeadingFont;
                default: font = h3HeadingFont;
                }
                
                print("number of hashes: \(numHashes)")
                
                attrStr.addAttribute(NSFontAttributeName, value: font, range: matchRange)
                
                // syntax range
                let preRange = NSMakeRange(matchRange.location, innerResult!.range.length)
                // style syntax
                if !self.hideSyntax {
                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: preRange)
                } else {
                    attrStr.addAttributes(hiddenAttributes, range: preRange)
                }
            })
        }
        
        result.append(headerMatcher)
        
        
        // underline header: header  or  header
        //                   ------      ======
        //
        let underlineHeaderMatcher = CallbackStyler(matcher: MarklightStyle.headersSetexRegex) { (attrStr, matchRange) in
            // apply markdown attributes
            attrStr.addAttribute(NSFontAttributeName, value: h1HeadingFont, range: matchRange)
            // match syntax
            MarklightStyle.headersSetexUnderlineRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                // style syntax else hide it
                if !self.hideSyntax {
                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
                } else {
                    attrStr.addAttributes(hiddenAttributes, range: innerResult!.range)
                }
            })
        }
        
        result.append(underlineHeaderMatcher)
        
        
        // MARK: LINKS & LISTS
        // -------------------
        
        // reference links:
        //
        let referenceLinkMatcher = CallbackStyler(matcher: MarklightStyle.referenceLinkRegex) { (attrStr, matchRange) in
            attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: matchRange)
        }
        
        result.append(referenceLinkMatcher)
        
        // lists:
        //
        let listMatcher = CallbackStyler(matcher: MarklightStyle.listRegex) { (attrStr, matchRange) in
            MarklightStyle.listOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
            })
        }
        
        result.append(listMatcher)
        
//        // anchors (links):
//        //
//        let anchorMatcher = CallbackStyler(matcher: MarklightStyle.anchorRegex) { (attrStr, matchRange) in
//            // apply markdown attributes
//            attrStr.addAttribute(NSFontAttributeName, value: codeFont, range: matchRange)
//            
//            MarklightStyle.openingSquareRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
//                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
//            })
//            
//            MarklightStyle.closingSquareRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
//                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
//            })
//            
//            MarklightStyle.parenRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
//                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
//                
//                if self.hideSyntax {
//                    let preRange = NSMakeRange(innerResult!.range.location, 1)
//                    let postRange = NSMakeRange(innerResult!.range.location + innerResult!.range.length - 1, 1)
//                    attrStr.addAttributes(hiddenAttributes, range: preRange)
//                    attrStr.addAttributes(hiddenAttributes, range: postRange)
//                }
//            })
//        }
//        
//        result.append(anchorMatcher)
//        
//        // inline anchors (links):
//        //
//        let inlineAnchorMatcher = CallbackStyler(matcher: MarklightStyle.imageInlineRegex) { (attrStr, matchRange) in
//            // apply markdown attributes
//            attrStr.addAttribute(NSFontAttributeName, value: codeFont, range: matchRange)
//            
//            var destinationLink: String?
//            
//            MarklightStyle.coupleRoundRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
//                
//                if !self.hideSyntax {
//                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
//                    
//                    var range = innerResult!.range
//                    range.location += 1
//                    range.length -= 2
//                    
//                    let substring = (attrStr.string as NSString).substring(with: range)
//                    guard substring.lengthOfBytes(using: .utf8) > 0 else { return }
//                    
//                    destinationLink = substring
//                    attrStr.addAttribute(NSLinkAttributeName, value: substring, range: range)
//                    
//                } else {
//                    attrStr.addAttributes(hiddenAttributes, range: innerResult!.range)
//                }
//            })
//            
//            MarklightStyle.openingSquareRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
//                
//                if !self.hideSyntax {
//                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
//                } else {
//                    attrStr.addAttributes(hiddenAttributes, range: innerResult!.range)
//                }
//            })
//            
//            MarklightStyle.closingSquareRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
//                
//                if !self.hideSyntax {
//                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
//                } else {
//                    attrStr.addAttributes(hiddenAttributes, range: innerResult!.range)
//                }
//            })
//            
//            guard let destinationLinkString = destinationLink else { return }
//            
//            MarklightStyle.coupleSquareRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
//                var range = innerResult!.range
//                range.location += 1
//                range.length -= 2
//                
//                let substring = (attrStr.string as NSString).substring(with: range)
//                guard substring.lengthOfBytes(using: .utf8) > 0 else { return }
//                
//                attrStr.addAttribute(NSLinkAttributeName, value: destinationLinkString, range: range)
//            })
//        }
//        
//        result.append(inlineAnchorMatcher)
        
        
        // MARK: CODE BLOCKS & QUOTES
        // --------------------------
        
        // inline code:
        //
        let codeSpanMatcher = CallbackStyler(matcher: MarklightStyle.codeSpanRegex) { (attrStr, matchRange) in
            // apply markdown attributes
            attrStr.addAttribute(NSFontAttributeName, value: codeFont, range: matchRange)
            attrStr.addAttribute(NSForegroundColorAttributeName, value: self.codeColor, range: matchRange)
            
            // TODO: range should be paragraph range
            MarklightStyle.codeSpanOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                if !self.hideSyntax {
                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
                } else {
                    attrStr.addAttributes(hiddenAttributes, range: innerResult!.range)
                }
            })
            
            // TODO: range should be paragraph range
            MarklightStyle.codeSpanClosingRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                if !self.hideSyntax {
                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
                } else {
                    attrStr.addAttributes(hiddenAttributes, range: innerResult!.range)
                }
            })
        }
        
        result.append(codeSpanMatcher)
        
        // code blocks:
        //
        let codeBlockMatcher = CallbackStyler(matcher: MarklightStyle.codeBlockRegex) { (attrStr, matchRange) in
            attrStr.addAttribute(NSFontAttributeName, value: codeFont, range: matchRange)
            attrStr.addAttribute(NSForegroundColorAttributeName, value: self.codeColor, range: matchRange)
        }
        
        result.append(codeBlockMatcher)
        
        // block quotes:
        //
        let blockQuoteMatcher = CallbackStyler(matcher: MarklightStyle.blockQuoteRegex) { (attrStr, matchRange) in
            attrStr.addAttribute(NSFontAttributeName, value: quoteFont, range: matchRange)
            attrStr.addAttribute(NSForegroundColorAttributeName, value: self.quoteColor, range: matchRange)
            attrStr.addAttribute(NSParagraphStyleAttributeName, value: self.quoteIndendationStyle, range: matchRange)
            
            MarklightStyle.blockQuoteOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                if !self.hideSyntax {
                    attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: innerResult!.range)
                } else {
                    attrStr.addAttributes(hiddenAttributes, range: innerResult!.range)
                }
            })
        }
        
        result.append(blockQuoteMatcher)
        
        
        // MARK: BOLD & ITALICS
        // --------------------
        
        // italics: *word* or _word_
        //
        let italicMatcher = CallbackStyler(matcher: MarklightStyle.italicRegex) { (attrStr, matchRange) in
            // apply markdown attributes
            attrStr.addAttribute(NSFontAttributeName, value: italicFont, range: matchRange)
            // ranges of syntax
            let preRange = NSMakeRange(matchRange.location, 1)
            let postRange = NSMakeRange(matchRange.location + matchRange.length - 1, 1)
            // style syntax else hide it
            if !self.hideSyntax {
                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: preRange)
                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: postRange)
            } else {
                attrStr.addAttributes(hiddenAttributes, range: preRange)
                attrStr.addAttributes(hiddenAttributes, range: postRange)
            }
        }
        
        result.append(italicMatcher)
        
        
        // FIXME: nested bold and italics
        
        // bold: **word** or __word__
        //
        let boldMatcher = CallbackStyler(matcher: MarklightStyle.boldRegex) { (attrStr, matchRange) in
            // apply markdown attributes
            attrStr.addAttribute(NSFontAttributeName, value: boldFont, range: matchRange)
            // ranges of syntax
            let preRange = NSMakeRange(matchRange.location, 2)
            let postRange = NSMakeRange(matchRange.location + matchRange.length - 2, 2)
            // style syntax else hide it
            if !self.hideSyntax {
                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: preRange)
                attrStr.addAttribute(NSForegroundColorAttributeName, value: self.syntaxColor, range: postRange)
            } else {
                attrStr.addAttributes(hiddenAttributes, range: preRange)
                attrStr.addAttributes(hiddenAttributes, range: postRange)
            }
        }
        
        result.append(boldMatcher)
        
        return result
    }
    
    /// Tabs are automatically converted to spaces as part of the transform
    /// this constant determines how "wide" those tabs become in spaces
    fileprivate static let _tabWidth = 4
    
    // MARK: Regex Patterns
    
    /*
     Head
     ======
     
     Subhead
     -------
     */
    
    fileprivate static let headerSetexPattern = [
        "^(.+?)",
        "\\p{Z}*",
        "\\n",
        "(=+|-+)     # $1 = string of ='s or -'s",
        "\\p{Z}*",
        "\\n+"
        ].joined(separator: "\n")
    
    fileprivate static let headersSetexRegex = Regex(pattern: headerSetexPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let setexUnderlinePattern = [
        "(=+|-+)     # $1 = string of ='s or -'s",
        "\\p{Z}*",
        "\\n+"
        ].joined(separator: "\n")
    
    fileprivate static let headersSetexUnderlineRegex = Regex(pattern: setexUnderlinePattern, options: [.allowCommentsAndWhitespace])
    
    /*
     # Head
     
     ## Subhead ##
     */
    
    fileprivate static let h1HeaderPattern = [
        "^(\\#)     # $1 = single # symbol",
        "\\p{Z}*",
        "(.+?)      # $2 = Header text",
        "\\p{Z}*",
        "\\#*         # optional closing #'s (not counted)",
        "\\n+"
        ].joined(separator: "\n")
    
    fileprivate static let h1HeaderRegex = Regex(pattern: h1HeaderPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let h2HeaderPattern = [
        "^(\\#{2})     # $1 = single # symbol",
        "\\p{Z}*",
        "(.+?)      # $2 = Header text",
        "\\p{Z}*",
        "\\#*         # optional closing #'s (not counted)",
        "\\n+"
        ].joined(separator: "\n")
    
    fileprivate static let h2HeaderRegex = Regex(pattern: h2HeaderPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let h3HeaderPattern = [
        "^(\\#{3})     # $1 = single # symbol",
        "\\p{Z}*",
        "(.+?)      # $2 = Header text",
        "\\p{Z}*",
        "\\#*         # optional closing #'s (not counted)",
        "\\n+"
        ].joined(separator: "\n")
    
    fileprivate static let h3HeaderRegex = Regex(pattern: h3HeaderPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let headerAtxPattern = [
        "^(\\#{1,6})  # $1 = string of #'s",
        "\\p{Z}*",
        "(.+?)        # $2 = Header text",
        "\\p{Z}*",
        "\\#*         # optional closing #'s (not counted)",
        "\\n+"
        ].joined(separator: "\n")
    
    fileprivate static let headersAtxRegex = Regex(pattern: headerAtxPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let headersAtxOpeningPattern = [
        "^(\\#{1,6})\\s*"
        ].joined(separator: "\n")
    
    fileprivate static let headersAtxOpeningRegex = Regex(pattern: headersAtxOpeningPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let headersAtxClosingPattern = [
        "\\#{1,6}\\n+"
        ].joined(separator: "\n")
    
    fileprivate static let headersAtxClosingRegex = Regex(pattern: headersAtxClosingPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    // MARK: Reference links
    
    /*
     TODO: we don't know how reference links are formed
     */
    
    fileprivate static let referenceLinkPattern = [
        "^\\p{Z}{0,\(_tabWidth - 1)}\\[([^\\[\\]]+)\\]:  # id = $1",
        "  \\p{Z}*",
        "  \\n?                   # maybe *one* newline",
        "  \\p{Z}*",
        "<?(\\S+?)>?              # url = $2",
        "  \\p{Z}*",
        "  \\n?                   # maybe one newline",
        "  \\p{Z}*",
        "(?:",
        "    (?<=\\s)             # lookbehind for whitespace",
        "    [\"(]",
        "    (.+?)                # title = $3",
        "    [\")]",
        "    \\p{Z}*",
        ")?                       # title is optional",
        "(?:\\n+|\\Z)"
        ].joined(separator: "")
    
    fileprivate static let referenceLinkRegex = Regex(pattern: referenceLinkPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    // MARK: Lists
    
    /*
     * First element
     * Second element
     */
    
    fileprivate static let _markerUL = "[*+-]"
    fileprivate static let _markerOL = "\\d+[.]"
    
    fileprivate static let _listMarker = "(?:\(_markerUL)|\(_markerOL))"
    fileprivate static let _wholeList = [
        "(                               # $1 = whole list",
        "  (                             # $2",
        "    \\p{Z}{0,\(_tabWidth - 1)}",
        "    (\(_listMarker))            # $3 = first list item marker",
        "    \\p{Z}+",
        "  )",
        "  (?s:.+?)",
        "  (                             # $4",
        "      \\z",
        "    |",
        "      \\n{2,}",
        "      (?=\\S)",
        "      (?!                       # Negative lookahead for another list item marker",
        "        \\p{Z}*",
        "        \(_listMarker)\\p{Z}+",
        "      )",
        "  )",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let listPattern = "(?:(?<=\\n\\n)|\\A\\n?)" + _wholeList
    
    fileprivate static let listRegex = Regex(pattern: listPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    fileprivate static let listOpeningRegex = Regex(pattern: _listMarker, options: [.allowCommentsAndWhitespace])
    
    // MARK: Anchors
    
    /*
     [Title](http://example.com)
     */
    
    fileprivate static let anchorPattern = [
        "(                                  # wrap whole match in $1",
        "    \\[",
        "        (\(getNestedBracketsPattern()))  # link text = $2",
        "    \\]",
        "",
        "    \\p{Z}?                        # one optional space",
        "    (?:\\n\\p{Z}*)?                # one optional newline followed by spaces",
        "",
        "    \\[",
        "        (.*?)                      # id = $3",
        "    \\]",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let anchorRegex = Regex(pattern: anchorPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let opneningSquarePattern = [
        "(\\[)"
        ].joined(separator: "\n")
    
    fileprivate static let openingSquareRegex = Regex(pattern: opneningSquarePattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let closingSquarePattern = [
        "\\]"
        ].joined(separator: "\n")
    
    fileprivate static let closingSquareRegex = Regex(pattern: closingSquarePattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let coupleSquarePattern = [
        "\\[(.*?)\\]"
        ].joined(separator: "\n")
    
    fileprivate static let coupleSquareRegex = Regex(pattern: coupleSquarePattern, options: [])
    
    fileprivate static let coupleRoundPattern = [
        "\\((.*?)\\)"
        ].joined(separator: "\n")
    
    fileprivate static let coupleRoundRegex = Regex(pattern: coupleRoundPattern, options: [])
    
    fileprivate static let parenPattern = [
        "(",
        "\\(                 # literal paren",
        "      \\p{Z}*",
        "      (\(getNestedParensPattern()))    # href = $3",
        "      \\p{Z}*",
        "      (               # $4",
        "      (['\"])         # quote char = $5",
        "      (.*?)           # title = $6",
        "      \\5             # matching quote",
        "      \\p{Z}*",
        "      )?              # title is optional",
        "  \\)",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let parenRegex = Regex(pattern: parenPattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let anchorInlinePattern = [
        "(                           # wrap whole match in $1",
        "    \\[",
        "        (\(getNestedBracketsPattern()))   # link text = $2",
        "    \\]",
        "    \\(                     # literal paren",
        "        \\p{Z}*",
        "        (\(getNestedParensPattern()))   # href = $3",
        "        \\p{Z}*",
        "        (                   # $4",
        "        (['\"])           # quote char = $5",
        "        (.*?)               # title = $6",
        "        \\5                 # matching quote",
        "        \\p{Z}*                # ignore any spaces between closing quote and )",
        "        )?                  # title is optional",
        "    \\)",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let anchorInlineRegex = Regex(pattern: anchorInlinePattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    // Mark: Images
    
    /*
     ![Title](http://example.com/image.png)
     */
    
    fileprivate static let imagePattern = [
        "(               # wrap whole match in $1",
        "!\\[",
        "    (.*?)       # alt text = $2",
        "\\]",
        "",
        "\\p{Z}?            # one optional space",
        "(?:\\n\\p{Z}*)?    # one optional newline followed by spaces",
        "",
        "\\[",
        "    (.*?)       # id = $3",
        "\\]",
        "",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let imageRegex = Regex(pattern: imagePattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let imageOpeningSquarePattern = [
        "(!\\[)"
        ].joined(separator: "\n")
    
    fileprivate static let imageOpeningSquareRegex = Regex(pattern: imageOpeningSquarePattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let imageClosingSquarePattern = [
        "(\\])"
        ].joined(separator: "\n")
    
    fileprivate static let imageClosingSquareRegex = Regex(pattern: imageClosingSquarePattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let imageInlinePattern = [
        "(                     # wrap whole match in $1",
        "  !\\[",
        "      (.*?)           # alt text = $2",
        "  \\]",
        "  \\s?                # one optional whitespace character",
        "  \\(                 # literal paren",
        "      \\p{Z}*",
        "      (\(getNestedParensPattern()))    # href = $3",
        "      \\p{Z}*",
        "      (               # $4",
        "      (['\"])       # quote char = $5",
        "      (.*?)           # title = $6",
        "      \\5             # matching quote",
        "      \\p{Z}*",
        "      )?              # title is optional",
        "  \\)",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let imageInlineRegex = Regex(pattern: imageInlinePattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    // MARK: Code
    
    /*
     ```
     Code
     ```
     
     Code
     */
    
    fileprivate static let codeBlockPattern = [
        "(?:\\n\\n|\\A\\n?)",
        "(                        # $1 = the code block -- one or more lines, starting with a space",
        "(?:",
        "    (?:\\p{Z}{\(_tabWidth)})       # Lines must start with a tab-width of spaces",
        "    .*\\n+",
        ")+",
        ")",
        "((?=^\\p{Z}{0,\(_tabWidth)}[^ \\t\\n])|\\Z) # Lookahead for non-space at line-start, or end of doc"
        ].joined(separator: "\n")
    
    fileprivate static let codeBlockRegex = Regex(pattern: codeBlockPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let codeSpanPattern = [
        "(?<![\\\\`])   # Character before opening ` can't be a backslash or backtick",
        "(`+)           # $1 = Opening run of `",
        "(?!`)          # and no more backticks -- match the full run",
        "(.+?)          # $2 = The code block",
        "(?<!`)",
        "\\1",
        "(?!`)"
        ].joined(separator: "\n")
    
    fileprivate static let codeSpanRegex = Regex(pattern: codeSpanPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let codeSpanOpeningPattern = [
        "(?<![\\\\`])   # Character before opening ` can't be a backslash or backtick",
        "(`+)           # $1 = Opening run of `"
        ].joined(separator: "\n")
    
    fileprivate static let codeSpanOpeningRegex = Regex(pattern: codeSpanOpeningPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let codeSpanClosingPattern = [
        "(?<![\\\\`])   # Character before opening ` can't be a backslash or backtick",
        "(`+)           # $1 = Opening run of `"
        ].joined(separator: "\n")
    
    fileprivate static let codeSpanClosingRegex = Regex(pattern: codeSpanClosingPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    // MARK: Block quotes
    
    /*
     > Quoted text
     */
    
    fileprivate static let blockQuotePattern = [
        "(                           # Wrap whole match in $1",
        "    (",
        "    ^\\p{Z}*>\\p{Z}?              # '>' at the start of a line",
        "        .+\\n               # rest of the first line",
        "    (.+\\n)*                # subsequent consecutive lines",
        "    \\n*                    # blanks",
        "    )+",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let blockQuoteRegex = Regex(pattern: blockQuotePattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let blockQuoteOpeningPattern = [
        "(^\\p{Z}*>\\p{Z})"
        ].joined(separator: "\n")
    
    fileprivate static let blockQuoteOpeningRegex = Regex(pattern: blockQuoteOpeningPattern, options: [.anchorsMatchLines])
    
    // MARK: Bold
    
    /*
     **Bold**
     __Bold__
     */
    
    fileprivate static let strictBoldPattern = "(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)\\2(?=\\S)(.*?\\S)\\2\\2(?!\\2)(?=[\\W_]|$)"
    
    fileprivate static let strictBoldRegex = Regex(pattern: strictBoldPattern, options: [.anchorsMatchLines])
    
    fileprivate static let boldPattern = "(\\*\\*|__) (?=\\S) (.+?[*_]*) (?<=\\S) \\1"
    
    fileprivate static let boldRegex = Regex(pattern: boldPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    // MARK: Italic
    
    /*
     *Italic*
     _Italic_
     */
    
    fileprivate static let strictItalicPattern = "(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)(?=\\S)((?:(?!\\2).)*?\\S)\\2(?!\\2)(?=[\\W_]|$)"
    
    fileprivate static let strictItalicRegex = Regex(pattern: strictItalicPattern, options: [.anchorsMatchLines])
    
    fileprivate static let italicPattern = "(\\*|_) (?=\\S) (.+?) (?<=\\S) \\1"
    
    fileprivate static let italicRegex = Regex(pattern: italicPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    fileprivate static let autolinkPattern = "((https?|ftp):[^'\">\\s]+)"
    
    fileprivate static let autolinkRegex = Regex(pattern: autolinkPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let autolinkPrefixPattern = "((https?|ftp)://)"
    
    fileprivate static let autolinkPrefixRegex = Regex(pattern: autolinkPrefixPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let autolinkEmailPattern = [
        "(?:mailto:)?",
        "(",
        "  [-.\\w]+",
        "  \\@",
        "  [-a-z0-9]+(\\.[-a-z0-9]+)*\\.[a-z]+",
        ")"
        ].joined(separator: "\n")
    
    fileprivate static let autolinkEmailRegex = Regex(pattern: autolinkEmailPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let mailtoPattern = "mailto:"
    
    fileprivate static let mailtoRegex = Regex(pattern: mailtoPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    
    /// maximum nested depth of [] and () supported by the transform;
    /// implementation detail
    fileprivate static let _nestDepth = 6
    
    fileprivate static var _nestedBracketsPattern = ""
    fileprivate static var _nestedParensPattern = ""
    
    /// Reusable pattern to match balanced [brackets]. See Friedl's
    /// "Mastering Regular Expressions", 2nd Ed., pp. 328-331.
    fileprivate static func getNestedBracketsPattern() -> String {
        // in other words [this] and [this[also]] and [this[also[too]]]
        // up to _nestDepth
        if (_nestedBracketsPattern.isEmpty) {
            _nestedBracketsPattern = repeatString([
                "(?>             # Atomic matching",
                "[^\\[\\]]+      # Anything other than brackets",
                "|",
                "\\["
                ].joined(separator: "\n"), _nestDepth) +
                repeatString(" \\])*", _nestDepth)
        }
        return _nestedBracketsPattern
    }
    
    /// Reusable pattern to match balanced (parens). See Friedl's
    /// "Mastering Regular Expressions", 2nd Ed., pp. 328-331.
    fileprivate static func getNestedParensPattern() -> String {
        // in other words (this) and (this(also)) and (this(also(too)))
        // up to _nestDepth
        if (_nestedParensPattern.isEmpty) {
            _nestedParensPattern = repeatString([
                "(?>            # Atomic matching",
                "[^()\\s]+      # Anything other than parens or whitespace",
                "|",
                "\\("
                ].joined(separator: "\n"), _nestDepth) +
                repeatString(" \\))*", _nestDepth)
        }
        return _nestedParensPattern
    }
    
    /// this is to emulate what's available in PHP
    fileprivate static func repeatString(_ text: String, _ count: Int) -> String {
        return Array(repeating: text, count: count).reduce("", +)
    }
}

/**
    Marklight struct that parses a `String` inside a `NSTextStorage`
 subclass, looking for markdown syntax to be highlighted. Internally many 
 regular expressions are used to detect the syntax. The highlights will be 
 applied as attributes to the `NSTextStorage`'s `NSAttributedString`. You should 
 create your our `NSTextStorage` subclass or use the readily available 
 `MarklightTextStorage` class.

 - see: `MarklightTextStorage`
*/



open class MarklightGroupStyler: NSObject {
    
    var stylers: [MarklightStyler]
    let style: MarklightStyle
    
    public override convenience init() {
        self.init(style: MarklightStyle(hideSyntax: true))
    }
    
    public init(style: MarklightStyle) {
        self.style = style
        stylers = self.style.defaultStylers()
        super.init()
    }
    

    // MARK: Processing
    
    /**
    This function should be called by the `-processEditing` method in your 
        `NSTextStorage` subclass and this is the function that is being called 
        for every change in the `UITextView`'s text.

    - parameter textStorage: your `NSTextStorage` subclass as the highlights
        will be applied to its attributed string through the `-addAttribute:value:range:` method.
    */
    
    // NEED TO RETURN THE STRING
    // NSNotFound
    @objc open func addMarkdownAttributes(_ input: NSAttributedString, editedRange: NSRange) {
        
        let wholeRange = NSMakeRange(0, (input.string as NSString).length)
        
        let paragraphRange = (input.string as NSString).paragraphRange(for: (editedRange.location == NSNotFound) ? wholeRange : editedRange)
        
//        let resultString = input.mutableCopy() as! NSMutableAttributedString
        
        self.stylers.forEach { matcher in
            matcher.processMatch(in: input as! NSMutableAttributedString, range: wholeRange)
        }
        
//        self.stylersPerParagraph.forEach { matcher in
//            matcher.processMatch(in: input as! NSMutableAttributedString, range: paragraphRange)
//
//        }
    }
    
    
}
