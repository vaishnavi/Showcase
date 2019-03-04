//
//  UIView+Utils.swift
//  Showcase
//
//  Created by Vaishnavi on 28/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    /// Returns the expected nib name of `view`.
    public static var nibName: String {
        return String(describing: self)
    }
    
    
    /// Convenience helper to create a `view` from it's associated xib if available.
    /// This method can infer the type based on the caller.
    ///
    /// - Parameter nibNameOrNil: The name of the nib to create a `view` from.
    /// - Returns: The `view` created from the associated xib or xib name specified.
    public static func fromNib(nibNameOrNil: String? = nil) -> Self? {
        return instantiateFromNib(nibNameOrNil: nibNameOrNil)
    }

    private static func instantiateFromNib<T: UIView>(nibNameOrNil: String? = nil) -> T? {
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = "\(nibName)".components(separatedBy: ".").last!
        }
        let bundle = Bundle(for: self)
        guard bundle.path(forResource: name, ofType: "nib") != nil else { return nil }
        let nib = UINib(nibName: name, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? T
    }
    
}
