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

public enum MarkdownElementType {
    
    public enum HeaderLevel {
        case h1, h2, h3
    }
    
    case header(HeaderLevel), bold, italic, numberList, bulletList, code, quote
}

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

// Called within processMatch
//
public typealias StylingCallback = (NSMutableAttributedString, NSRange) -> MarkdownRange


public struct MarkdownRange {
    
    public let wholeRange: NSRange
    public let preRange: NSRange?
    public let postRange: NSRange?
    
    public var contentRange: NSRange {
        get {
            let syntaxLength = (preRange?.length ?? 0) + (postRange?.length ?? 0)
            return NSMakeRange(wholeRange.location + (preRange?.length ?? 0), wholeRange.length - syntaxLength)
        }
    }
}


// Parses an input string and calls the styling callback with the match range.
//
open class MarklightStyler: NSObject {
    
    public let matcher: Regex
    public let styling: StylingCallback
    public var ranges = [MarkdownRange]()

    init(matcher: Regex, styling: @escaping StylingCallback) {
        self.matcher = matcher
        self.styling = styling
    }
    
    public func processMatch(in string: NSMutableAttributedString, range: NSRange) {
        self.ranges.removeAll()
        matcher.matches(string.string, range: range) { (result) in
            self.ranges.append(self.styling(string, result!.range))
        }
    }
}


// Defines the Markdown styling attributes.
//
open class MarklightStyle: NSObject {
    
    // Styling Attribues
    //
    public var syntaxAttributes:        [String: Any]!
    public var h1HeadingAttributes:     [String: Any]!
    public var h2HeadingAttributes:     [String: Any]!
    public var h3HeadingAttributes:     [String: Any]!
    public var italicAttributes:        [String: Any]!
    public var boldAttributes:          [String: Any]!
    public var boldItalicAttributes:    [String: Any]!
    public var listSyntaxAttributes:    [String: Any]!
    public var listItemAttributes:      [String: Any]!
    public var codeAttributes:          [String: Any]!
    public var blockQuoteAttributes:    [String: Any]!
    public var hiddenAttributes:        [String: Any]!
    
    /**
     Dynamic type font text style, default `UIFontTextStyleBody`.
     
     */
    
    // Dynamic type font text styles.
    // - see:
    // [TextStyles](xcdoc://?url=developer.apple.com/library/ios/documentation/UIKit/Reference/UIFontDescriptor_Class/index.html#//apple_ref/doc/constant_group/Text_Styles)
    //
    public var fontTextStyle : String = UIFontTextStyle.body.rawValue
    
    // If the markdown syntax should be hidden or visible.
    //
    public var hideSyntax = false
    
    // We are validating the user provided fontTextStyle `String` to match the
    // system supported ones.
    //
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
    
    // -----------------------------------------------------------
    
    public override init() {
        super.init()
        configureDefaults()
    }
    
    private func configureDefaults() {
        
        let textSize = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle(rawValue: fontTextStyleValidated)).pointSize
        
        syntaxAttributes = [
            NSForegroundColorAttributeName: UIColor.lightGray
        ]
        
        h1HeadingAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 28)
        ]
        
        h2HeadingAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24)
        ]
        
        h3HeadingAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)
        ]
        
        italicAttributes = [
            NSFontAttributeName: UIFont.italicSystemFont(ofSize: textSize)
        ]
        
        boldAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: textSize)
        ]
        
        boldItalicAttributes = [
            NSFontAttributeName: UIFont(name: "Helvetica-BoldOblique", size: textSize)!
        ]
        
        let listParagraphStyle = NSMutableParagraphStyle()
        listParagraphStyle.paragraphSpacingBefore = 4.0
        listParagraphStyle.paragraphSpacing = 4.0
        
        listItemAttributes = [
            NSParagraphStyleAttributeName: listParagraphStyle
        ]
        
        listSyntaxAttributes = [
            NSForegroundColorAttributeName: UIColor.gray
        ]
        
        codeAttributes = [
            NSFontAttributeName: UIFont(name: "Menlo", size: textSize)!,
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        let quoteParagraphStyle = NSMutableParagraphStyle()
        quoteParagraphStyle.headIndent = 20.0
        
        blockQuoteAttributes = [
            NSFontAttributeName: UIFont(name: "Menlo", size: textSize)!,
            NSForegroundColorAttributeName: UIColor.darkGray,
            NSParagraphStyleAttributeName: quoteParagraphStyle
        ]

        hiddenAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 0.1),
            NSForegroundColorAttributeName: UIColor.clear
        ]
    }
}


// Define default stylers
//
extension MarklightStyle {
    
    func headerStylerForType(_ type: MarkdownElementType.HeaderLevel) -> MarklightStyler {
        
        let matcher: Regex
        
        switch type {
        case .h1: matcher = MarklightStyle.h1HeaderRegex
        case .h2: matcher = MarklightStyle.h2HeaderRegex
        case .h3: matcher = MarklightStyle.h3HeaderRegex
        }
        
        let headerMatcher = MarklightStyler(matcher: matcher) { (attrStr, matchRange) in
            
            var preRange = NSMakeRange(0, 0)
            var postRange = NSMakeRange(0, 0)
            
            MarklightStyle.headersAtxOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                
                let attributes: [String: Any]
                
                // we set attributes here so in case that attributes
                // are changed externally, they will be applied
                switch type {
                case .h1: attributes = self.h1HeadingAttributes
                case .h2: attributes = self.h2HeadingAttributes
                case .h3: attributes = self.h3HeadingAttributes
                }
                
                // apply markdown style
                attrStr.addAttributes(attributes, range: matchRange)
                
                // syntax range & style
                preRange = NSMakeRange(matchRange.location, innerResult!.range.length)
                
                if !self.hideSyntax {
                    attrStr.addAttributes(self.syntaxAttributes, range: preRange)
                } else {
                    attrStr.addAttributes(self.hiddenAttributes, range: preRange)
                }
            })
            
            // trailing #'s are considered syntax
            MarklightStyle.headersAtxClosingRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                
                postRange = innerResult!.range
                
                if !self.hideSyntax {
                    attrStr.addAttributes(self.syntaxAttributes, range: postRange)
                } else {
                    attrStr.addAttributes(self.hiddenAttributes, range: postRange)
                }
            })
            
            return MarkdownRange(wholeRange: matchRange, preRange: preRange, postRange: postRange)
        }
        
        return headerMatcher
    }
    
    
    func strictItalicStyler() -> MarklightStyler {
        
        let strictItalicMatcher = MarklightStyler(matcher: MarklightStyle.strictItalicRegex) { (attrStr, matchRange) in
            
            let substring = (attrStr.string as NSString).substring(with: NSMakeRange(matchRange.location, 1))
            
            // strict italic require start of string or following pattern to preceed syntax
            let regex = try! NSRegularExpression(pattern: "\\W|_", options: [])
            
            var start = 0
            
            if matchRange.location != 0 && regex.numberOfMatches(in: substring, options: [], range: NSMakeRange(0, 1)) > 0 {
                start = 1
            }
            
            let adjustedRange = NSMakeRange(matchRange.location + start, matchRange.length - start)
            
            // apply markdown style
            attrStr.addAttributes(self.italicAttributes, range: adjustedRange)
            
            let preRange = NSMakeRange(matchRange.location + start, 1)
            let postRange = NSMakeRange(matchRange.location + matchRange.length - 1, 1)
            
            if !self.hideSyntax {
                attrStr.addAttributes(self.syntaxAttributes, range: preRange)
                attrStr.addAttributes(self.syntaxAttributes, range: postRange)
            } else {
                attrStr.addAttributes(self.hiddenAttributes, range: preRange)
                attrStr.addAttributes(self.hiddenAttributes, range: postRange)
            }
            
            return MarkdownRange(wholeRange: adjustedRange, preRange: preRange, postRange: postRange)
        }
        
        return strictItalicMatcher
    }
    
    func strictBoldStyler() -> MarklightStyler {
        
        let strictBoldMatcher = MarklightStyler(matcher: MarklightStyle.strictBoldRegex) { (attrStr, matchRange) in
            
            let substring = (attrStr.string as NSString).substring(with: NSMakeRange(matchRange.location, 1))
            
            // strict bold require start of string or following pattern to preceed syntax
            let regex = try! NSRegularExpression(pattern: "\\W|_", options: [])
            
            var start = 0
            
            if matchRange.location != 0 && regex.numberOfMatches(in: substring, options: [], range: NSMakeRange(0, 1)) > 0 {
                start = 1
            }
            
            let adjustedRange = NSMakeRange(matchRange.location + start, matchRange.length - start)
            
            // apply markdown style
            attrStr.addAttributes(self.boldAttributes, range: adjustedRange)
            
            let preRange = NSMakeRange(matchRange.location + start, 2)
            let postRange = NSMakeRange(matchRange.location + matchRange.length - 2, 2)
            
            if !self.hideSyntax {
                attrStr.addAttributes(self.syntaxAttributes, range: preRange)
                attrStr.addAttributes(self.syntaxAttributes, range: postRange)
            } else {
                attrStr.addAttributes(self.hiddenAttributes, range: preRange)
                attrStr.addAttributes(self.hiddenAttributes, range: postRange)
            }
            
            return MarkdownRange(wholeRange: adjustedRange, preRange: preRange, postRange: postRange)
        }
        
        return strictBoldMatcher
    }
    
    func italicStyler() -> MarklightStyler {
        
        let italicMatcher = MarklightStyler(matcher: MarklightStyle.italicRegex) { (attrStr, matchRange) in
            
            attrStr.addAttributes(self.italicAttributes, range: matchRange)
            
            let preRange = NSMakeRange(matchRange.location, 1)
            let postRange = NSMakeRange(matchRange.location + matchRange.length - 1, 1)
            
            if !self.hideSyntax {
                attrStr.addAttributes(self.syntaxAttributes, range: preRange)
                attrStr.addAttributes(self.syntaxAttributes, range: postRange)
            } else {
                attrStr.addAttributes(self.hiddenAttributes, range: preRange)
                attrStr.addAttributes(self.hiddenAttributes, range: postRange)
            }
            
            return MarkdownRange(wholeRange: matchRange, preRange: preRange, postRange: postRange)
        }
        
        return italicMatcher
    }
    
    
    func boldStyler() -> MarklightStyler {
        
        let boldMatcher = MarklightStyler(matcher: MarklightStyle.boldRegex) { (attrStr, matchRange) in
            
            var italicRanges: [NSRange] = []
            
            // get all ranges that contain italics
            attrStr.enumerateAttribute(NSFontAttributeName, in: matchRange, options: [], using: { (attrValue, attrRange, _) in
                
                let italicFont = self.italicAttributes[NSFontAttributeName] as! UIFont
                if attrValue as! UIFont == italicFont {
                    italicRanges.append(attrRange)
                }
            })
            
            // style whole match range bold
            attrStr.addAttributes(self.boldAttributes, range: matchRange)
            
            // style italic ranges bolditalic
            for range in italicRanges {
                attrStr.addAttributes(self.boldItalicAttributes, range: range)
            }
            
            // ranges of syntax
            let preRange = NSMakeRange(matchRange.location, 2)
            let postRange = NSMakeRange(matchRange.location + matchRange.length - 2, 2)
            
            if !self.hideSyntax {
                attrStr.addAttributes(self.syntaxAttributes, range: preRange)
                attrStr.addAttributes(self.syntaxAttributes, range: postRange)
                // need to reset font attribute since italic matcher can match empty
                // italics (** or __)
                attrStr.addAttribute(NSFontAttributeName, value: self.boldAttributes[NSFontAttributeName] as! UIFont, range: preRange)
                attrStr.addAttribute(NSFontAttributeName, value: self.boldAttributes[NSFontAttributeName] as! UIFont, range: postRange)
            } else {
                attrStr.addAttributes(self.hiddenAttributes, range: preRange)
                attrStr.addAttributes(self.hiddenAttributes, range: postRange)
            }
            
            return MarkdownRange(wholeRange: matchRange, preRange: preRange, postRange: postRange)
        }
        
        return boldMatcher
    }
    
    
    func underlineHeaderStyler() -> MarklightStyler {
    
        let underlineHeaderMatcher = MarklightStyler(matcher: MarklightStyle.headersSetexRegex) { (attrStr, matchRange) in
            
            var postRange: NSRange?
            
            // apply markdown attributes
            attrStr.addAttributes(self.h1HeadingAttributes, range: matchRange)
            // match syntax
            MarklightStyle.headersSetexUnderlineRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                
                postRange = innerResult!.range
                
                // style syntax else hide it
                if !self.hideSyntax {
                    attrStr.addAttributes(self.syntaxAttributes, range: postRange!)
                } else {
                    attrStr.addAttributes(self.hiddenAttributes, range: postRange!)
                }
            })
            
            return MarkdownRange(wholeRange: matchRange, preRange: nil, postRange: postRange)
        }
        
        return underlineHeaderMatcher
    }
    

    func numberListStyler() -> MarklightStyler {
        
        let listMatcher = MarklightStyler(matcher: MarklightStyle.numberListItemRegex) { (attrStr, matchRange) in

            var preRange: NSRange?
            attrStr.addAttributes(self.listItemAttributes, range: matchRange)
            
            MarklightStyle.listOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                preRange = innerResult!.range
                attrStr.addAttributes(self.listSyntaxAttributes, range: preRange!)
            })
            
            return MarkdownRange(wholeRange: matchRange, preRange: preRange, postRange: nil)
        }
        
        return listMatcher
    }
    
    
    func bulletListStyler() -> MarklightStyler {
        
        let listMatcher = MarklightStyler(matcher: MarklightStyle.bulletListItemRegex) { (attrStr, matchRange) in
            
            var preRange: NSRange?
            attrStr.addAttributes(self.listItemAttributes, range: matchRange)
            
            MarklightStyle.listOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                preRange = innerResult!.range
                attrStr.addAttributes(self.listSyntaxAttributes, range: preRange!)
            })
            
            return MarkdownRange(wholeRange: matchRange, preRange: preRange, postRange: nil)
        }
        
        return listMatcher
    }

    
    func inlineCodeStyler() -> MarklightStyler {
        
        let codeSpanMatcher = MarklightStyler(matcher: MarklightStyle.codeSpanRegex) { (attrStr, matchRange) in
            
            var preRange: NSRange?
            var postRange: NSRange?
            
            attrStr.addAttributes(self.codeAttributes, range: matchRange)
            
            preRange = NSMakeRange(matchRange.location, 1)
            postRange = NSMakeRange(NSMaxRange(matchRange) - 1, 1)

            if !self.hideSyntax {
                attrStr.addAttributes(self.syntaxAttributes, range: preRange!)
                attrStr.addAttributes(self.syntaxAttributes, range: postRange!)
            } else {
                attrStr.addAttributes(self.hiddenAttributes, range: preRange!)
                attrStr.addAttributes(self.hiddenAttributes, range: postRange!)
            }
            
            return MarkdownRange(wholeRange: matchRange, preRange: preRange, postRange: postRange)
        }
        
        return codeSpanMatcher
    }
    
    
    func blockCodeStyler() -> MarklightStyler {
        
        let codeBlockMatcher = MarklightStyler(matcher: MarklightStyle.codeBlockRegex) { (attrStr, matchRange) in
            attrStr.addAttributes(self.codeAttributes, range: matchRange)
            return MarkdownRange(wholeRange: matchRange, preRange: nil, postRange: nil)
        }
        
        return codeBlockMatcher
    }
    
    
    func blockQuoteStyler() -> MarklightStyler {
        
        let blockQuoteMatcher = MarklightStyler(matcher: MarklightStyle.blockQuoteRegex) { (attrStr, matchRange) in
            
            var preRange: NSRange?
            
            attrStr.addAttributes(self.blockQuoteAttributes, range: matchRange)
            
            MarklightStyle.blockQuoteOpeningRegex.matches(attrStr.string, range: matchRange, completion: { (innerResult) in
                
                preRange = innerResult!.range
                
                if !self.hideSyntax {
                    attrStr.addAttributes(self.syntaxAttributes, range: preRange!)
                } else {
                    attrStr.addAttributes(self.hiddenAttributes, range: preRange!)
                }
            })
            
            return MarkdownRange(wholeRange: matchRange, preRange: preRange, postRange: nil)
        }
        
        return blockQuoteMatcher
    }
    
    
    // MARK: Regex Patterns
    
    /// Tabs are automatically converted to spaces as part of the transform
    /// this constant determines how "wide" those tabs become in spaces
    fileprivate static let _tabWidth = 4
    
    /// When true, italic & bold patterns can match without content
    fileprivate static var allowEmptyMatches = true
    
    /// When true, italic & bold patterns allow spaces after opening syntax
    /// and before closing syntax
    fileprivate static var allowSpaces = true
    
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
    
    // pattern: start of line : 1 to 6 '#' symbols : 0 or more tabs or spaces : 0 or more of any symbol except newline : end of line
    fileprivate static let headerRegex = Regex(pattern: "(^\\#{1,6})(.*)$", options: [.anchorsMatchLines])
    
    fileprivate static let headersAtxOpeningPattern = "^(\\#{1,6})\\s*"
    
    fileprivate static let headersAtxOpeningRegex = Regex(pattern: headersAtxOpeningPattern, options: [.anchorsMatchLines])
    
    fileprivate static let headersAtxClosingPattern = "\\#{1,6}$"
    
    fileprivate static let headersAtxClosingRegex = Regex(pattern: headersAtxClosingPattern, options: [.anchorsMatchLines])
    
    // needs at least one space before header content
    fileprivate static let h1HeaderRegex = Regex(pattern: "(^\\#{1}[\\t ]+)(.*)$", options: [.anchorsMatchLines])
    fileprivate static let h2HeaderRegex = Regex(pattern: "(^\\#{2}[\\t ]+)(.*)$", options: [.anchorsMatchLines])
    fileprivate static let h3HeaderRegex = Regex(pattern: "(^\\#{3}[\\t ]+)(.*)$", options: [.anchorsMatchLines])
    
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
    
    fileprivate static let _markerUL = "[*+-][\\t ]+"
    fileprivate static let _markerOL = "\\d+[.][\\t ]+"
    
    fileprivate static let _listMarker = "(?:\(_markerUL)|\(_markerOL))"
    fileprivate static let listOpeningRegex = Regex(pattern: _listMarker, options: [])
    
    // matches a single list item such as '1. hello world' or '- hello world'
    //
    // pattern explantation -> start of line : list prefix : at least 1 tab or space : 0 or more chars (any except newline)
    fileprivate static let numberListItemPattern = "(?:^\(_markerOL))(.)*"
    fileprivate static let bulletListItemPattern = "(?:^\(_markerUL))(.)*"
    fileprivate static let numberListItemRegex = Regex(pattern: numberListItemPattern, options: [.anchorsMatchLines])
    fileprivate static let bulletListItemRegex = Regex(pattern: bulletListItemPattern, options: [.anchorsMatchLines])
    
    // matches a whole list (one or more consecutive list items with no empty lines between)
    //
    // pattern explanation -> same as list item pattern : newline and list item : 0 or more of prev token
    fileprivate static let wholeNumberListPattern = "(\(numberListItemPattern))(\\n\(numberListItemPattern))*"
    fileprivate static let wholeBulletListPattern = "(\(bulletListItemPattern))(\\n\(bulletListItemPattern))*"
    fileprivate static let wholeNumberListRegex = Regex(pattern: wholeNumberListPattern, options: [.anchorsMatchLines])
    fileprivate static let wholeBulletListRegex = Regex(pattern: wholeBulletListPattern, options: [.anchorsMatchLines])
    
    
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
    
    fileprivate static let opneningSquarePattern = "(\\[)"
    fileprivate static let openingSquareRegex = Regex(pattern: opneningSquarePattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let closingSquarePattern = "\\]"
    fileprivate static let closingSquareRegex = Regex(pattern: closingSquarePattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let coupleSquarePattern = "\\[(.*?)\\]"
    fileprivate static let coupleSquareRegex = Regex(pattern: coupleSquarePattern, options: [])
    
    fileprivate static let coupleRoundPattern = "\\((.*?)\\)"
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
    
    fileprivate static let imageOpeningSquarePattern = "(!\\[)"
    fileprivate static let imageOpeningSquareRegex = Regex(pattern: imageOpeningSquarePattern, options: [.allowCommentsAndWhitespace])
    
    fileprivate static let imageClosingSquarePattern = "(\\])"
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
        "(.*?)          # $2 = The code block",
        "(?<!`)",
        "\\1",
        "(?!`)"
        ].joined(separator: "\n")
    
    fileprivate static let singleTickCodeSpanPattern = [
        "(?<![\\\\`])   # Character before opening ` can't be a backslash or backtick",
        "(`)            # $1 = Opening run of `",
        "(.*?)          # $2 = The code block",
        "\\1",
        "(?!`)"
        ].joined(separator: "\n")
    
    fileprivate static let codeSpanRegex = Regex(pattern: singleTickCodeSpanPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let codeSpanOpeningPattern = [
        "(?<![\\\\`])   # Character before opening ` can't be a backslash or backtick",
        "(`|`{3})       # $1 = Opening run of `"
        ].joined(separator: "\n")
    
    fileprivate static let codeSpanOpeningRegex = Regex(pattern: codeSpanOpeningPattern, options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators])
    
    fileprivate static let codeSpanClosingPattern = [
        "(?<![\\\\`])   # Character before opening ` can't be a backslash or backtick",
        "(`|`{3})      # $1 = Opening run of `"
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
    
    fileprivate static let blockQuoteOpeningPattern = "(^\\p{Z}*>\\p{Z})"
    
    fileprivate static let blockQuoteOpeningRegex = Regex(pattern: blockQuoteOpeningPattern, options: [.anchorsMatchLines])
    
    // MARK: Bold
    
    /*
     **Bold**
     __Bold__
     */
    
    fileprivate static let strictBoldPattern = "(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)\\2(?=\\S)(.*?\\S)\\2\\2(?!\\2)(?=[\\W_]|$)"
    
    fileprivate static let strictBoldRegex = Regex(pattern: strictBoldPattern, options: [.anchorsMatchLines])
    
    fileprivate static let boldPattern = "(\\*\\*|__) \(allowSpaces ? "" : "(?=\\S)") (.\(allowEmptyMatches ? "*" : "+")?[*_]*) \(allowSpaces ? "" : "(?<=\\S)") \\1"
    
    fileprivate static let boldRegex = Regex(pattern: boldPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    // MARK: Italic
    
    /*
     *Italic*
     _Italic_
     */
    
    fileprivate static let strictItalicPattern = "(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)(?=\\S)((?:(?!\\2).)*?\\S)\\2(?!\\2)(?=[\\W_]|$)"
    
    fileprivate static let strictItalicRegex = Regex(pattern: strictItalicPattern, options: [.anchorsMatchLines])
    
    fileprivate static let italicPattern = "(\\*|_) \(allowSpaces ? "" : "(?=\\S)") (.\(allowEmptyMatches ? "*" : "+")?) \(allowSpaces ? "" : "(?<=\\S)") \\1"
    
    fileprivate static let italicRegex = Regex(pattern: italicPattern, options: [.allowCommentsAndWhitespace, .anchorsMatchLines])
    
    // MARK: Links
    
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


// MarklightGroupStyler defines are single Markdown parser. It collects 
// multiple stylers, each responsible for parsing and styling a unit
// of markdown syntax.
//
open class MarklightGroupStyler: NSObject {
    
    let style:                  MarklightStyle
    var stylers:                [MarklightStyler]
    var stylersPerParagraph:    [MarklightStyler]
    
    // standard stylers
    var h1HeaderStyler:         MarklightStyler
    var h2HeaderStyler:         MarklightStyler
    var h3HeaderStyler:         MarklightStyler
    var underlineHeaderStyler:  MarklightStyler
    var strictItalicStyler:     MarklightStyler
    var strictBoldStyler:       MarklightStyler
    var italicStyler:           MarklightStyler
    var boldStyler:             MarklightStyler
    var numberListStyler:       MarklightStyler
    var bulletListStyler:       MarklightStyler
    var inlineCodeStyler:       MarklightStyler
    var blockCodeStyler:        MarklightStyler
    var blockQuoteStyler:       MarklightStyler
    
    public override convenience init() {
        self.init(style: MarklightStyle())
        self.style.hideSyntax = true
    }
    
    public init(style: MarklightStyle) {
        self.style =            style
        h1HeaderStyler =        style.headerStylerForType(.h1)
        h2HeaderStyler =        style.headerStylerForType(.h2)
        h3HeaderStyler =        style.headerStylerForType(.h3)
        underlineHeaderStyler = style.underlineHeaderStyler()
        strictItalicStyler =    style.strictItalicStyler()
        strictBoldStyler =      style.strictBoldStyler()
        italicStyler =          style.italicStyler()
        boldStyler =            style.boldStyler()
        numberListStyler =      style.numberListStyler()
        bulletListStyler =      style.bulletListStyler()
        inlineCodeStyler =      style.inlineCodeStyler()
        blockCodeStyler =       style.blockCodeStyler()
        blockQuoteStyler =      style.blockQuoteStyler()
        
        stylersPerParagraph = [h1HeaderStyler, h2HeaderStyler, h3HeaderStyler, strictItalicStyler, strictBoldStyler, italicStyler, boldStyler]
        stylers = [underlineHeaderStyler, numberListStyler, bulletListStyler, inlineCodeStyler, blockCodeStyler, blockQuoteStyler]
        
        super.init()
    }

    // MARK: Processing
    
    @objc open func addMarkdownAttributes(_ input: NSAttributedString, editedRange: NSRange) {
        
        let wholeRange = NSMakeRange(0, (input.string as NSString).length)
        let paragraphRange = (input.string as NSString).paragraphRange(for: (editedRange.location == NSNotFound) ? wholeRange : editedRange)
        
        self.stylers.forEach { matcher in
            matcher.processMatch(in: input as! NSMutableAttributedString, range: wholeRange)
        }
        
        self.stylersPerParagraph.forEach { matcher in
            matcher.processMatch(in: input as! NSMutableAttributedString, range: paragraphRange)
        }
        
        removeEmptyItalicRanges()
    }
    
    open func rangesForElementType(_ type: MarkdownElementType) -> [MarkdownRange] {
        
        switch type {
        case .header(let level):
            switch level {
            case .h1:       return h1HeaderStyler.ranges
            case .h2:       return h2HeaderStyler.ranges
            case .h3:       return h3HeaderStyler.ranges
            }
        case .italic:       return strictItalicStyler.ranges + italicStyler.ranges
        case .bold:         return strictBoldStyler.ranges + boldStyler.ranges
        case .numberList:   return numberListStyler.ranges
        case .bulletList:   return bulletListStyler.ranges
        case .code:         return inlineCodeStyler.ranges
        case .quote:        return blockQuoteStyler.ranges
        }
    }
    
    // Hack: for bold ranges, remove italic ranges for empty tokens (** or __) that exist in bold syntax
    private func removeEmptyItalicRanges() {
        
        for range in boldStyler.ranges {
            
            var rangesToDelete = [Int]()
            
            for (i, italicRange) in italicStyler.ranges.enumerated() {
                // if nonempty italic range
                if italicRange.wholeRange.length > 3 {
                    continue
                }
                // if pre/post range contained within italic range, then equal.
                // italic range includes preceeding space, thats why we check if union is
                // equal the italic range and not the pre/post range
                let isPreRange = NSEqualRanges(NSUnionRange(italicRange.wholeRange, range.preRange!), italicRange.wholeRange)
                let isPostRange = NSEqualRanges(NSUnionRange(italicRange.wholeRange, range.postRange!), italicRange.wholeRange)
                if isPreRange || isPostRange {
                    rangesToDelete.append(i)
                }
            }
        
            for index in rangesToDelete.reversed() {
                italicStyler.ranges.remove(at: index)
            }
        }
    }
}
