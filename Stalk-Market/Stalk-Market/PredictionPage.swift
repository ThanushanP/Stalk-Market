//
//  PredictionPage.swift
//  Stalk-Market
//
//  Created by Thanushan Pirapakaran on 2024-05-29.
//

import SwiftUI
import Foundation
import Charts

struct PredictionPage: View {
    var ticker: String
    var body: some View {
        NavigationView{
            ZStack {
                Image("Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.3)
                VStack{
                    Spacer()
                    TickerInfoBox(ticker: ticker)
                }
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Gradient(colors: [
                Color(UIColor(named: "lightPurple")!), Color(UIColor(named: "darkPurple")!), Color(UIColor(named: "darkPurple")!)]).opacity(0.6))
        }
    }
}
struct graphBox: View {
    var ticker:String
    @State private var scale: CGFloat = 1.0
    var chartDataArray: [(type:String, data:[ChartData])]
    var minPrice: Double {
        chartDataArray.flatMap { $0.data }.min(by: { $0.price < $1.price })?.price ?? 0
    }

    var maxPrice: Double {
        chartDataArray.flatMap { $0.data }.max(by: { $0.price < $1.price })?.price ?? 0
    }
    var body: some View{
        ScrollView([.horizontal,.vertical]) {
                VStack{
                    Chart {
                        ForEach(chartDataArray, id: \.type) { series in
                            ForEach(series.data) { item in
                                LineMark(
                                    x: .value("Date", item.date_x),
                                    y: .value("Price", item.price)
                                )
                            }
                            .foregroundStyle(by: .value("Type", series.type))
                        }
                    }
                    .frame(minWidth: 500, minHeight: 500)
                    .padding()
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartYScale(domain: [minPrice,maxPrice])
                    .scaleEffect(scale)
                    .gesture(MagnificationGesture()
                        .onChanged{ value in
                            self.scale = value.magnitude
                        })
                }
                .frame(minWidth: 500, minHeight: 500)
        }
        .background()
        .opacity(0.8)
        .cornerRadius(20.0)
        .scenePadding(.top)
        .scenePadding(.leading)
        .scenePadding(.trailing)
    }
}
struct TickerInfoBox: View {
    var ticker:String
    @State var cost:String = "0"
    @State var currency:String = "USD"
    @State var name:String = "Name"
    @State var chartDataArray: [(type:String, data:[ChartData])] = []
    var body: some View{
        VStack{
            graphBox(ticker: ticker,chartDataArray: chartDataArray)
            VStack{
                Text(name)
                    .scenePadding([.top,.leading,.bottom])
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                
                Text(ticker)
                    .scenePadding(.leading)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Current Cost: \(cost) \(currency)")
                    .scenePadding([.bottom,.leading])
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background()
            .opacity(0.8)
            .cornerRadius(20.0)
            .padding()
            .onAppear{
//                getStockInfo()
                getPred()
            }
        }
    }
    
    func getPred(){
        if let url = URL(string: "http://127.0.0.1:5000/predict"){
            var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let jsonPayload = ["ticker": ticker]
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonPayload, options: [])
                    request.httpBody = jsonData
                } catch {
                    print("Error: Unable to serialize JSON payload")
                    return
                }

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse ?? "Response")
                    if let unwrapData = data{
                        let tickerList:predictionDecoder = try! JSONDecoder().decode(predictionDecoder.self, from: unwrapData)
                        let pred = tickerList.pred
//                        var test = tickerList.test
                        let train = tickerList.train
                        let trainArray = train.sorted { $0.key < $1.key }
                        var trainDataArray: [ChartData] = []
                        for (dateString, value) in trainArray {
                            let chartData = ChartData(dateString: dateString, value: value)
                            trainDataArray.append(chartData)
                        }
                        let predArray = pred.sorted { $0.key < $1.key }
                        var predDataArray: [ChartData] = []
                        for (dateString, value) in predArray {
                            let chartData = ChartData(dateString: dateString, value: value)
                            predDataArray.append(chartData)
                        }
                        chartDataArray = [(type:"Previous",data:trainDataArray),
                                          (type:"Prediction",data:predDataArray)]
                    }
                    else{
                        print("Failed Fetch")
                    }
                }
            })

            dataTask.resume()
        }
        else {
            print("API Key not found")
        }
    }
    
    func getStockInfo(){
        if let key = ProcessInfo.processInfo.environment["YahooAPI2"]{
            let headers = [
                "X-RapidAPI-Key": key,
                "X-RapidAPI-Host": "yahoo-finance127.p.rapidapi.com"
            ]

            let request = NSMutableURLRequest(url: NSURL(string: "https://yahoo-finance127.p.rapidapi.com/price/"+ticker)! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers

            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse ?? "Response")
                    if let unwrapData = data{
                        let tickerList:SearchAPIPrice = try! JSONDecoder().decode(SearchAPIPrice.self, from: unwrapData)
                        cost = tickerList.regularMarketOpen.fmt
                        currency = tickerList.currency
                        name = tickerList.shortName
                    }
                    else{
                        print("Failed Fetch")
                    }
                }
            })

            dataTask.resume()
        }
        else {
            print("API Key not found")
        }
    }
}
struct ChartData: Identifiable {
    let id = UUID()
    let date_x: Date
    let price: Double

    init(dateString: String, value: Double) {
        
        let dateTemp = dateString.components(separatedBy: " ")[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateTemp) else {
            fatalError("Failed to convert dateString to Date.")
        }
        self.date_x = date
        self.price = value
    }
}
struct predictionDecoder: Decodable{
    var pred: [String: Double]
    var train: [String: Double]
    var test: [String: Double]
}


struct SearchAPIPrice: Decodable{
    var currency: String
    var shortName: String
    var regularMarketOpen: price
}

struct price: Decodable{
    var fmt:String
}

#Preview {
    PredictionPage(ticker: "VFV.TO")
}
