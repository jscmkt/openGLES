//
//  MusicListViewController.swift
//  RXDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class MusicListViewController: UIViewController {
    //tableview对象
    lazy var tableView: UITableView = {
        let newTableView = UITableView(frame: CGRect(x: 20, y: 100, width: 400, height: 400))
        return newTableView
    }()
    //歌曲对象数据源
    let musicListViewModel = MusicListViewModel()

    //负责对象销毁
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        //将数据源数据绑定tableview上
        musicListViewModel.data
            .bind(to: tableView.rx.items(cellIdentifier:"musicCell")) { _, music, cell in
                cell.textLabel?.text = music.name
                cell.detailTextLabel?.text = music.singer
            }.disposed(by: disposeBag)

        //tableView点击响应
        tableView.rx.modelSelected(Music.self).subscribe(onNext: { music in
            print("你选中的歌曲信息【\(music)】")
        }).disposed(by: disposeBag)
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
