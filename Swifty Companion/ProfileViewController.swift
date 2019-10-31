//
//  ProfileViewController.swift
//  Swifty Companion
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/22.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation
import Alamofire

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var searchText: String = "";
    let uid = "9554ff91768454cce24fb6f4efca1395b486ae8b641b854ba26d67be97cea80a";
    let secret = "69652bd0c93cb26822a9a97218f23490cb935af92357f7c50d05037f1767ce01";
    var skills: [(String, String, Float)] = [];
    var projects: [(String, String, UIColor)] = [];
    
    var token: String = ""{
        didSet{
            if searchText != "" && searchText.split(separator: " ").count == 1 {
                getUserInfo()
            }
            else{
                self.performSegue(withIdentifier: "backToSearch", sender: self);
            }
        }
    }
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var wallet: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var mainLevel: UILabel!
    @IBOutlet weak var levelsTableView: UITableView!
    @IBOutlet weak var projectsTableView: UITableView!
    @IBOutlet weak var profileDP: UIImageView!
    @IBOutlet weak var campus: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var mainLevelProgressBar: UIProgressView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == levelsTableView{
            return skills.count;
        }
        else if tableView == projectsTableView{
            return projects.count;
        }
        return 0;
    }
    
    func handleLevels(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell") as! LevelTableViewCell;
        cell.skillItem = skills[indexPath.row];
        
        return cell;
    }
    
    func handleProjects(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell") as! ProjectTableViewCell;
        cell.projItem = projects[indexPath.row];
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == levelsTableView{
            return handleLevels(tableView: tableView, indexPath: indexPath);
        }
        else if tableView == projectsTableView{
            return handleProjects(tableView: tableView, indexPath: indexPath);
        }
        return UITableViewCell();
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
                        self.checkToken();
                    }
                }catch(let err){
                    print(err)
                }
            }
        }
        task.resume()
    }
    
    private func checkToken() {
        let url = URL(string: "https://api.intra.42.fr/oauth/token/info")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        Alamofire.request(request as URLRequestConvertible).validate().responseJSON {
            response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print("The current token still has ", json["expires_in_seconds"], "seconds to go.")
                }
            case .failure:
                print("The token has expired or something.")
                self.createToken()
            }
        }
    }

    func getUserInfo() {
        if let url = URL(string: "https://api.intra.42.fr/v2/users/" + searchText){
            var request = URLRequest(url: url);
            request.httpMethod = "GET";
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization");
            
            Alamofire.request(request as URLRequestConvertible).validate().responseJSON {
                response in
                
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
    //                    print(json)
                        DispatchQueue.main.async {
                            self.loadDP(url: json["image_url"].string ?? "")
                            self.username.text = json["login"].string;
                            self.wallet.text = "Wallet : "+(json["wallet"].string ?? "0") + "₳";
                            self.points.text = "Correction Points: " + (json["correction_point"].number?.stringValue ?? "0");
                            self.email.text = json["email"].string;
                            self.campus.text = json["campus"][0]["name"].string;
                            self.fullName.text = json["displayname"].string;
                            let mLevel = json["cursus_users"][0]["level"].stringValue;
                            let mlevelArr = mLevel.split(separator: ".");
                            if mlevelArr.count == 2{
                                self.mainLevel.text = "Level : " + mlevelArr[0] + " - " + mlevelArr[1] + "%";
                                self.mainLevelProgressBar.setProgress(Float(mlevelArr[1])!/Float(100.0), animated: true);
                            }
                            else{
                                self.mainLevel.text = "Level : " + mLevel + " - 0%";
                            }
                            
                            self.handleSkillsTableUpdate(json: json);
                            self.handleProjectsTableUpdate(json: json);
                        }
                        self.loadingView.isHidden = true;
                    }else{
                        self.performSegue(withIdentifier: "backToSearch", sender: self);
                    }
                case .failure:
                    self.performSegue(withIdentifier: "backToSearch", sender: self);
                    print("Something went wrong.")
                }
            }
        }else{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "backToSearch", sender: self);
            }
        }
    }
    
    func handleSkillsTableUpdate(json: JSON){
        let skillsArr = json["cursus_users"][0]["skills"];
        var indexPaths: [IndexPath] = [];
        
        for c in 0..<skillsArr.count{
            
            let levelArr = skillsArr[c]["level"].stringValue.split(separator: ".");
            var skillItem: (String, String, Float)?;
            if levelArr.count == 2{
                skillItem = (skillsArr[c]["name"].stringValue, levelArr[0] + " - " + levelArr[1] + "%", Float(levelArr[1])!/Float(100.0));
            }
            else{
                skillItem = (skillsArr[c]["name"].stringValue, skillsArr[c]["level"].stringValue + " - 0%", Float(0.0));
            }
            self.skills.append(skillItem!);
            indexPaths.append(IndexPath(row: self.skills.count - 1, section: 0));
        }
        self.levelsTableView.beginUpdates();
        self.levelsTableView.insertRows(at: indexPaths, with: .automatic);
        self.levelsTableView.endUpdates();
    }
    
    func handleProjectsTableUpdate(json: JSON){
        let projArr = json["projects_users"];
        var indexPaths: [IndexPath] = [];
        for c in 0..<projArr.count{
            
            var color: UIColor = UIColor(red: CGFloat(1.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0));
            if projArr[c]["validated?"].stringValue == "true"{
                color = UIColor(red: CGFloat(0.0), green: CGFloat(0.7), blue: CGFloat(0.0), alpha: CGFloat(1.0));
            }

            var percentage: String = "-";
            if projArr[c]["final_mark"].stringValue != ""{
                percentage = projArr[c]["final_mark"].stringValue + "%";
            }
            let projItem = (projArr[c]["project"]["slug"].stringValue, percentage, color);
            self.projects.append(projItem);
            indexPaths.append(IndexPath(row: self.projects.count - 1, section: 0));
        }
        self.projectsTableView.beginUpdates();
        self.projectsTableView.insertRows(at: indexPaths, with: .automatic);
        self.projectsTableView.endUpdates();
    }
    
    func loadDP(url: String){
        let url = URL(string: url)!

        let session = URLSession(configuration: .default)

        let downloadPicTask = session.dataTask(with: url) {
            (data, response, error) in
            
            if let err = error {
                print(err)
            } else {
                if (response as? HTTPURLResponse) != nil {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self.profileDP.image = image;
                        }
                    } else {
                        print("Couldn't get image")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "backToSearch"{
            if let vc = segue.destination as? ViewController{
                vc.errorMessage = "Something went wrong. Try a valid input."
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingView.isHidden = false;
        self.profileDP.layer.borderColor = UIColor.white.cgColor;
        self.profileDP.layer.borderWidth = 1;
        self.profileDP.layer.cornerRadius = self.profileDP.frame.height / 2;
        self.profileDP.layer.masksToBounds = true;
        if searchText == "" || searchText.split(separator: " ").count > 1{
            performSegue(withIdentifier: "backToSearch", sender: self);
        }
        else{
            checkToken();
        }
    }
}
