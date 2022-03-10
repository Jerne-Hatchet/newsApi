//
//  Extensions.swift
//  NewsApi
//
//  Created by Jerne Hatchet on 02.03.2022.
//

import Foundation
import UIKit

extension UIImageView{
  func imageFrom(url:URL){
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url){
        if let image = UIImage(data:data){
          DispatchQueue.main.async{
            self?.image = image
          }
        }
      }
    }
  }
}
