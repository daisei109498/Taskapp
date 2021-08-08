//
//  CategoryAddViewController.swift
//  taskapp
//
//  Created by dslog sys on 2021/08/08.
//

import UIKit
import RealmSwift    // 追加する

class CategoryAddViewController: UIViewController {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryAddButton: UIButton!
    
    let realm = try! Realm()    // 追加する
    var categoryArray = try! Realm().objects(Category.self) // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    @IBAction func categoryAdd(_ sender: Any) {
        if categoryTextField.text == "" {
            // アラートダイアログを生成
            let alertController = UIAlertController(title: "エラー",
                                                    message: "カテゴリ名を入力して下さい",
                                                    preferredStyle: UIAlertController.Style.alert)
            // CANCELボタンがタップされた時の処理なし
            let cancelButton = UIAlertAction(title: "とじる",
                                             style: UIAlertAction.Style.cancel, handler: nil)
            // CANCELボタンを追加
            alertController.addAction(cancelButton)
            // アラートダイアログを表示
            present(alertController, animated: true, completion: nil)
        }else{
            let category = Category()
                try! realm.write {
                category.name = categoryTextField.text!
                self.realm.add(category, update: .modified)
                }
            categoryArray = try! Realm().objects(Category.self) // ←追加
                    
            // アラートダイアログを生成
            let alertController = UIAlertController(title: "登録完了",
                                                    message: "カテゴリ名\(categoryTextField.text!)を追加しました。",
                                                    preferredStyle: UIAlertController.Style.alert)
            // CANCELボタンがタップされた時の処理なし
            let cancelButton = UIAlertAction(title: "とじる",
                                             style: UIAlertAction.Style.cancel, handler: nil)
            // CANCELボタンを追加
            alertController.addAction(cancelButton)
            // アラートダイアログを表示
            present(alertController, animated: true, completion: nil)
            
        }
        //reset
        categoryTextField.text = ""
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
