//
//  Utilities.swift
//
//  Created by CS193p Instructor.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

extension String {
    func madeUnique(withRespectTo otherStrings: [String]) -> String {
        var possiblyUnique = self
        var uniqueNumber = 1
        while otherStrings.contains(possiblyUnique) {
            possiblyUnique = self + " \(uniqueNumber)"
            uniqueNumber += 1
        }
        return possiblyUnique
    }
}

extension Array where Element: Equatable {
    var uniquified: [Element] {
        var elements = [Element]()
        forEach { if !elements.contains($0) { elements.append($0) } }
        return elements
    }
}

extension NSAttributedString {
    func withFontScaled(by factor: CGFloat) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.setFont(mutable.font?.scaled(by: factor))
        return mutable
    }
    var font: UIFont? {
        get { return attribute(.font, at: 0, effectiveRange: nil) as? UIFont }
    }
}

extension String {
    func attributedString(withTextStyle style: UIFont.TextStyle, ofSize size: CGFloat) -> NSAttributedString {
        let font = UIFont.preferredFont(forTextStyle: style).withSize(size)
        return NSAttributedString(string: self, attributes: [.font:font])
    }
}

extension NSMutableAttributedString {
    func setFont(_ newValue: UIFont?) {
        if newValue != nil { addAttributes([.font:newValue!], range: NSMakeRange(0, length)) }
    }
}

extension UIFont {
    func scaled(by factor: CGFloat) -> UIFont { return withSize(pointSize * factor) }
}

extension UILabel {
    func stretchToFit() {
        let oldCenter = center
        sizeToFit()
        center = oldCenter
    }
}



extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}

extension UIView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIDocument.State: CustomStringConvertible {
    public var description: String {
        return [
            UIDocument.State.normal.rawValue:".normal",
            UIDocument.State.closed.rawValue:".closed",
            UIDocument.State.inConflict.rawValue:".inConflict",
            UIDocument.State.savingError.rawValue:".savingError",
            UIDocument.State.editingDisabled.rawValue:".editingDisabled",
            UIDocument.State.progressAvailable.rawValue:".progressAvailable"
            ][rawValue] ?? String(rawValue)
    }
}
