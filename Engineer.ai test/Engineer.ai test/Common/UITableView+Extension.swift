//
//  UITableView+Extension.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func registerAndGet<T:UITableViewCell>(cell identifier:T.Type) -> T?{
        let cellID = String(describing: identifier)
        
        if let cell = self.dequeueReusableCell(withIdentifier: cellID) as? T {
            return cell
        } else {
            //regiser
            self.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
            return self.dequeueReusableCell(withIdentifier: cellID) as? T
            
        }
    }
    
    func register<T:UITableViewCell>(cell identifier:T.Type) {
        let cellID = String(describing: identifier)
        self.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    func getCell<T:UITableViewCell>(identifier:T.Type) -> T?{
        let cellID = String(describing: identifier)
        guard let cell = self.dequeueReusableCell(withIdentifier: cellID) as? T else {
            print("cell not exist")
            return nil
        }
        return cell
    }
    
    var isLoading:Bool?{
        if let _ = self.superview {
            for v in self.superview!.subviews {
                if v is UIActivityIndicatorView {
                    if v.accessibilityValue == "tableLoader" {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func startLoading(withExtraTop: CGFloat = 10) {
        self.stopLoading(withAnimation: false)
        
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = UIColor.black
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.accessibilityValue = "tableLoader"
        activityIndicatorView.startAnimating()
        
        self.superview?.addSubview(activityIndicatorView)
        
        self.contentInset = UIEdgeInsets(top: activityIndicatorView.frame.height + 20, left: 0, bottom: 0, right: 0)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let verticalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: withExtraTop)
        
        self.superview?.addConstraints([horizontalConstraint,verticalConstraint])
    }
    
    func stopLoading(withAnimation: Bool = false) {
        if let _ = self.superview {
            for v in self.superview!.subviews {
                if v is UIActivityIndicatorView {
                    if v.accessibilityValue == "tableLoader" {
                        v.removeFromSuperview()
                        
                    }
                }
            }
            if withAnimation {
                UIView.animate(withDuration: 0.2) {
                    if Thread.isMainThread {
                        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    } else {
                        DispatchQueue.main.async {
                            self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        }
                    }
                }
            } else {
                if Thread.isMainThread {
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                } else {
                    DispatchQueue.main.async {
                        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    }
                }
            }
        }
    }
}

