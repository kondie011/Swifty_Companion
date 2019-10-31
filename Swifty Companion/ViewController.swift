//
//  ViewController.swift
//  Swifty Companion
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/22.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let uid = "9554ff91768454cce24fb6f4efca1395b486ae8b641b854ba26d67be97cea80a";
    let secret = "69652bd0c93cb26822a9a97218f23490cb935af92357f7c50d05037f1767ce01";
    var token: String?;
    var errorMessage: String = "";
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var wtcIcon: UIImageView!
    
    @IBAction func searchButt(_ sender: UIButton) {
        
    }
    
   func createToken(){
       let url = URL(string: "https://api.intra.42.fr/oauth/token")
       let bearer = ((uid + ":" + secret).data(using:  String.Encoding.utf8))!.base64EncodedString(options:NSData.Base64EncodingOptions(rawValue: 0));
       let request = NSMutableURLRequest(url: url!);
       request.httpMethod = "POST";
       request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type");
       request.setValue("Basic " + bearer, forHTTPHeaderField: "Authorization");
       request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8);
       
       let task = URLSession.shared.dataTask(with: request as URLRequest){
           (data, response, error) in
          
           if let err = error{
               print(err)
           }
           else if let d = data{
               do {
                   if let dict : NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as?     NSDictionary{
                       self.token = dict["access_token"]! as! String
                       print(dict);
                   }
               }catch(let err){
                   print(err)
               }
           }
       }
       task.resume()
   }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createToken();
    }
    
    @IBAction func unWindSegue(segue: UIStoryboardSegue){
        if segue.identifier == "backToSearch" {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert);
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil);
            alert.addAction(action);
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil);
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search"{
            if let vc = segue.destination as? ProfileViewController{
                vc.searchText = searchText.text ?? "";
                vc.token = token ?? "";
            }
        }
    }
}

