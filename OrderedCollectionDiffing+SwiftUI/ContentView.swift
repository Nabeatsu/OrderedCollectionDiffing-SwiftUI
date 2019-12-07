//
//  ContentView.swift
//  OrderedCollectionDiffing+SwiftUI
//
//  Created by tanabe.nobuyuki on 2019/12/08.
//  Copyright © 2019 tanabe.nobuyuki. All rights reserved.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var models: [SampleModel] = []
    @State private var backUpModels: [SampleModel] = []
    
    var apiClient: APIClient = SampleAPIClient()
    
    func getList() {
        apiClient.get(completion: { models in
            self.models = models
        })
    }
    
    func delete(at offsets: IndexSet) {
        var newModels = models
        newModels.remove(atOffsets: offsets)
        update(with: newModels)
    }
    
    func update(with newModels: [SampleModel]) {
        let diff = newModels.difference(from: models)
        for change in diff {
            switch change {
            case .insert(let offset, let model, _):
                apiClient.create(model, at: offset)
            case .remove(let offset, let model, _):
                apiClient.delete(model, at: offset)
            }
        }
        backUpModels = models
        models = newModels
    }
    
    func undo(with backUpModels: [SampleModel]) {
        update(with: backUpModels)
        self.backUpModels = []
    }
    
    var body: some View {
        return VStack {
            List {
                ForEach(models, id: \.self) { model in
                    SampleRow(model: model)
                }
                .onDelete(perform: delete(at:))
            }
            HStack {
                Button(action: {
                    self.getList()
                }) {
                    Text("デフォルトデータ作成")
                }.disabled(!models.isEmpty)
                
                Button(action: {
                    var newModels = self.models
                    newModels.append(SampleModel())
                    self.update(with: newModels)
                }) {
                    Text("追加")
                }
                Button(action: {
                    self.update(with: [])
                }) {
                    Text("全削除")
                }.disabled(models.isEmpty)
                
                Button(action: {
                    self.undo(with: self.backUpModels)
                }) {
                    Text("Undo")
                }.disabled(backUpModels.isEmpty)
            }
            Spacer()
        }
    }
}

struct SampleRow: View {
    var model: SampleModel
    var body: some View {
        Text(model.id)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SampleModel: Identifiable, Hashable {
    var id = UUID().uuidString
}

protocol APIClient {
    func create(_ data: SampleModel, at: Int)
    func delete(_ data: SampleModel, at: Int)
    func get(completion: @escaping ([SampleModel]) -> Void)
}

struct SampleAPIClient: APIClient {
    func create(_ data: SampleModel, at: Int) {
        print("\(at)番目に\(data.id)を追加しました")
    }
    
    func delete(_ data: SampleModel, at: Int) {
        print("\(at)番目の\(data.id)を削除しました")
    }
    
    func get(completion: @escaping ([SampleModel]) -> Void) {
        completion(
            Array.init(repeating: SampleModel(), count: 10)
        )
    }
}
