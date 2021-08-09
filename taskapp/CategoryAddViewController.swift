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
    
    var realm = try! Realm()    // 追加する
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
            var category = Category()
              category.name = categoryTextField.text!
              categoryArray = try! Realm().objects(Category.self)
               .filter("name == %@", category.name)
             if categoryArray.count == 0{
                    category = Category()
                    categoryArray = try! Realm().objects(Category.self)
                try! realm.write {
                    category.id = categoryArray.max(ofProperty: "id")! + 1
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
             }else{
                // アラートダイアログを生成
                let alertController = UIAlertController(title: "エラー",
                                                        message: "既に登録済みのカテゴリ名です。",
                                                        preferredStyle: UIAlertController.Style.alert)
                // CANCELボタンがタップされた時の処理なし
                let cancelButton = UIAlertAction(title: "とじる",
                                                 style: UIAlertAction.Style.cancel, handler: nil)
                // CANCELボタンを追加
                alertController.addAction(cancelButton)
                // アラートダイアログを表示
                present(alertController, animated: true, completion: nil)
                    
             }
        }
        //reset
        categoryTextField.text = ""
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

}
