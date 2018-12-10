//
//  UITableView+Extension.swift
//  OutGoingCall
//
//  Created by Plivo on 12/7/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

extension UITableView {
    
    /**
     * returns the indexpath of the cell in which the view presented.
     */
    func indexPath(forView: UIView) -> IndexPath? {
        let viewCenterRelativeToTableview = self.convert(CGPoint.init(x: forView.bounds.midX, y: forView.bounds.midY), from: forView)
        return self.indexPathForRow(at: viewCenterRelativeToTableview)
    }
}
