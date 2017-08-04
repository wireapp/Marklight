//
//  MarklightTests.swift
//  MarklightTests
//
//  Created by Matteo Gavagnin on 30/12/15.
//  Copyright © 2016 MacTeo. All rights reserved.
//

import XCTest
@testable import Marklight

class MarklightTests: XCTestCase {
    
    let textStorage = MarklightTextStorage()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAtxH1() {
        // given
        let string = "# Header"
        let attributedString = NSAttributedString(string: string)
        
        // when
        self.textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let syntaxAttribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            // assert syntax color is correct and applies to prefix (first 2 chars)
            XCTAssert(syntaxAttribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 2)
        } else {
            XCTFail()
        }
        
        if let headerAttribute = textStorage.attribute(NSFontAttributeName, at: 2, effectiveRange: &range!) as? UIFont {
            // assert header font is correct and applies to header text
            XCTAssert(headerAttribute == textStorage.style.h1HeadingAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 6)
        } else {
            XCTFail()
        }
    }
    
    func testAtxH2() {
        // given
        let string = "## Header"
        let attributedString = NSAttributedString(string: string)
        
        // when
        self.textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let syntaxAttribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            // assert syntax color is correct and applies to prefix (first 3 chars)
            XCTAssert(syntaxAttribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 3)
        } else {
            XCTFail()
        }
        
        if let headerAttribute = textStorage.attribute(NSFontAttributeName, at: 3, effectiveRange: &range!) as? UIFont {
            // assert header font is correct and applies to header text
            XCTAssert(headerAttribute == textStorage.style.h2HeadingAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 6)
        } else {
            XCTFail()
        }
    }
    
    func testAtxH3() {
        // given
        let string = "### Header"
        let attributedString = NSAttributedString(string: string)
        
        // when
        self.textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let syntaxAttribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            // assert syntax color is correct and applies to prefix (first 3 chars)
            XCTAssert(syntaxAttribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 4)
        } else {
            XCTFail()
        }
        
        if let headerAttribute = textStorage.attribute(NSFontAttributeName, at: 4, effectiveRange: &range!) as? UIFont {
            // assert header font is correct and applies to header text
            XCTAssert(headerAttribute == textStorage.style.h3HeadingAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 6)
        } else {
            XCTFail()
        }
    }
    
    func testSetexH1() {
        // given
        let string = ["Header", "========", ""].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let attribute = textStorage.attribute(NSFontAttributeName, at: 2, effectiveRange: &range!) as? UIFont {
            XCTAssert(attribute == textStorage.style.h1HeadingAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 7)
        } else {
            XCTFail()
        }
    }
    
    func testSetexH2() {
        // given
        let string = ["Header", "------", ""].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let attribute = textStorage.attribute(NSFontAttributeName, at: 2, effectiveRange: &range!) as? UIFont {
            XCTAssert(attribute == textStorage.style.h1HeadingAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 7)
        } else {
            XCTFail()
        }
    }
    
//    func testReferenceLinks() {
//        let string = ["[Example][1]","", "[1]: http://example.com/", ""].joined(separator: "\n")
//        let attributedString = NSAttributedString(string: string)
//        self.textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
//        var range : NSRange? = NSMakeRange(0, 1)
//        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
//            XCTAssert(attribute == UIColor.lightGray)
//            XCTAssert(range?.length == 1)
//        } else {
//            XCTFail()
//        }
//        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 8, effectiveRange: &range!) as? UIColor {
//            XCTAssert(attribute == UIColor.lightGray)
//            XCTAssert(range?.length == 2)
//        } else {
//            XCTFail()
//        }
//        // TODO: test following attributes
//    }
    
    func testList() {
        // given
        let string = ["* First", "* Second", "* Third"].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, string.lengthOfBytes(using: .utf8))
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.listSyntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 8, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.listSyntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
    }
    
//    func testAnchor() {
//        let string = ["[Example](http://www.example.com)",""].joined(separator: "\n")
//        let attributedString = NSAttributedString(string: string)
//        self.textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
//        var range : NSRange? = NSMakeRange(0, 1)
//        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
//            XCTAssert(attribute == UIColor.lightGray)
//            XCTAssert(range?.length == 1)
//        } else {
//            XCTFail()
//        }
//        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 8, effectiveRange: &range!) as? UIColor {
//            XCTAssert(attribute == UIColor.lightGray)
//            // TODO: exetend test
//            XCTAssert(range?.length == 2)
//        } else {
//            XCTFail()
//        }
//    }
    
    // TODO: test anchor inline?
    
//    func testImage() {
//        let string = ["![Example](http://www.example.com/image.png)",""].joined(separator: "\n")
//        let attributedString = NSAttributedString(string: string)
//        self.textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
//        var range : NSRange? = NSMakeRange(0, string.lengthOfBytes(using: .utf8))
//        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
//            XCTAssert(attribute == UIColor.lightGray)
//            XCTAssert(range?.length == 2)
//        } else {
//            XCTFail()
//        }
//        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 9, effectiveRange: &range!) as? UIColor {
//            XCTAssert(attribute == UIColor.lightGray)
//            // TODO: exetend test
//            XCTAssert(range?.length == 2)
//        } else {
//            XCTFail()
//        }
//    }
    
    func testCodeBlock() {
        // given
        let string = ["`","func testCodeBlock()","`"].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSFontAttributeName, at: 1, effectiveRange: &range!) as? UIFont {
            XCTAssert(attribute == textStorage.style.codeAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 22)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 23, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
    }
    
    func testIndentedCodeBlock() {
        // given
        let string = ["    func testCodeBlock() {","    }",""].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.codeAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 33)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSFontAttributeName, at: 0, effectiveRange: &range!) as? UIFont {
            XCTAssert(attribute == textStorage.style.codeAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 33)
        } else {
            XCTFail()
        }
    }
    
    func testCodeSpan() {
        // given
        let string = ["This is a phrase with inline `code`",""].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 29, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
        if let attribute = self.textStorage.attribute(NSFontAttributeName, at: 30, effectiveRange: &range!) as? UIFont {
            XCTAssert(attribute == textStorage.style.codeAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 4)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 34, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
    }
    
    func testQuote() {
        // given
        let string = ["> This is a quoted line","> This another one", ""].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, 1)
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 2)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 24, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 2)
        } else {
            XCTFail()
        }
    }
    
    func testItalic() {
        // given
        let string = ["*italic* word", ""].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, string.lengthOfBytes(using: .utf8))
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSFontAttributeName, at: 1, effectiveRange: &range!) as? UIFont {
            XCTAssert(attribute == textStorage.style.italicAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 6)
        } else {
            XCTFail()
        }
        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 7, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 1)
        } else {
            XCTFail()
        }
    }
    
    func testBold() {
        // given
        let string = ["**italic** word", ""].joined(separator: "\n")
        let attributedString = NSAttributedString(string: string)
        
        // when
        textStorage.replaceCharacters(in: NSMakeRange(0, 0), with: attributedString)
        
        // then
        var range : NSRange? = NSMakeRange(0, string.lengthOfBytes(using: .utf8))
        if let attribute = textStorage.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 2)
        } else {
            XCTFail()
        }
        if let attribute = textStorage.attribute(NSFontAttributeName, at: 2, effectiveRange: &range!) as? UIFont {
            XCTAssert(attribute == textStorage.style.boldAttributes[NSFontAttributeName] as! UIFont)
            XCTAssert(range?.length == 6)
        } else {
            XCTFail()
        }
        if let attribute = self.textStorage.attribute(NSForegroundColorAttributeName, at: 8, effectiveRange: &range!) as? UIColor {
            XCTAssert(attribute == textStorage.style.syntaxAttributes[NSForegroundColorAttributeName] as! UIColor)
            XCTAssert(range?.length == 2)
        } else {
            XCTFail()
        }
    }
    
    // TODO: test the remaining markdown syntax
}
