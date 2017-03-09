//
//  Extensions.swift
//  Ring_Test
//
//  Created by Christopher Truman on 3/5/17.
//  Copyright © 2017 Christopher Truman. All rights reserved.
//

import UIKit

extension UIView {
    var translates: Bool { get { return translatesAutoresizingMaskIntoConstraints } set { translatesAutoresizingMaskIntoConstraints = newValue } }
    convenience init(translates: Bool) { self.init(); self.translates = translates }
    
    func constrain(_ constants : (attr: NSLayoutAttribute, const: CGFloat)..., toItem: UIView? = nil) {
        for constantPair in constants {
            NSLayoutConstraint(item: self, attribute: constantPair.attr, relatedBy: .equal, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : constantPair.attr, multiplier: 1.0, constant:constantPair.const).isActive = true
        }
    }
    
    func constrain(_ attributes: NSLayoutAttribute..., relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute, multiplier: CGFloat = 1.0) {
        for attribute in attributes {
            let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: multiplier, constant:constant).isActive = true
        }
    }
    
    func constraint(_ attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal, constant: CGFloat = 0.0, toItem: UIView? = nil, toAttribute: NSLayoutAttribute = .notAnAttribute, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let toAttributeChoice = toAttribute == .notAnAttribute ? attribute : toAttribute
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: (toItem == nil) ? .notAnAttribute : toAttributeChoice, multiplier: multiplier, constant:constant)
    }
}

// Taken from: https://gist.github.com/jinthagerman/009c85b7bbd0a40dcbba747e89a501bf
struct DateComponentUnitFormatter {
    
    private struct DateComponentUnitFormat {
        let unit: Calendar.Component
        
        let singularUnit: String
        let pluralUnit: String
        
        let futureSingular: String
        let pastSingular: String
    }
    
    private let formats: [DateComponentUnitFormat] = [
        
        DateComponentUnitFormat(unit: .year,
                                singularUnit: "year",
                                pluralUnit: "years",
                                futureSingular: "Next year",
                                pastSingular: "Last year"),
        
        DateComponentUnitFormat(unit: .month,
                                singularUnit: "month",
                                pluralUnit: "months",
                                futureSingular: "Next month",
                                pastSingular: "Last month"),
        
        DateComponentUnitFormat(unit: .weekOfYear,
                                singularUnit: "week",
                                pluralUnit: "weeks",
                                futureSingular: "Next week",
                                pastSingular: "Last week"),
        
        DateComponentUnitFormat(unit: .day,
                                singularUnit: "day",
                                pluralUnit: "days",
                                futureSingular: "Tomorrow",
                                pastSingular: "Yesterday"),
        
        DateComponentUnitFormat(unit: .hour,
                                singularUnit: "hour",
                                pluralUnit: "hours",
                                futureSingular: "In an hour",
                                pastSingular: "An hour ago"),
        
        DateComponentUnitFormat(unit: .minute,
                                singularUnit: "minute",
                                pluralUnit: "minutes",
                                futureSingular: "In a minute",
                                pastSingular: "A minute ago"),
        
        DateComponentUnitFormat(unit: .second,
                                singularUnit: "second",
                                pluralUnit: "seconds",
                                futureSingular: "Just now",
                                pastSingular: "Just now"),
        
        ]
    
    func string(forDateComponents dateComponents: DateComponents, useNumericDates: Bool) -> String {
        for format in self.formats {
            let unitValue: Int
            
            switch format.unit {
            case .year:
                unitValue = dateComponents.year ?? 0
            case .month:
                unitValue = dateComponents.month ?? 0
            case .weekOfYear:
                unitValue = dateComponents.weekOfYear ?? 0
            case .day:
                unitValue = dateComponents.day ?? 0
            case .hour:
                unitValue = dateComponents.hour ?? 0
            case .minute:
                unitValue = dateComponents.minute ?? 0
            case .second:
                unitValue = dateComponents.second ?? 0
            default:
                assertionFailure("Date does not have requried components")
                return ""
            }
            
            switch unitValue {
            case 2 ..< Int.max:
                return "\(unitValue) \(format.pluralUnit) ago"
            case 1:
                return useNumericDates ? "\(unitValue) \(format.singularUnit) ago" : format.pastSingular
            case -1:
                return useNumericDates ? "In \(-unitValue) \(format.singularUnit)" : format.futureSingular
            case Int.min ..< -1:
                return "In \(-unitValue) \(format.pluralUnit)"
            default:
                break
            }
        }
        
        return "Just now"
    }
}

extension Date {
    
    func timeAgoSinceNow(useNumericDates: Bool = false) -> String {
        
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let components = calendar.dateComponents(unitFlags, from: self, to: now)
        
        let formatter = DateComponentUnitFormatter()
        return formatter.string(forDateComponents: components, useNumericDates: useNumericDates)
    }
}
