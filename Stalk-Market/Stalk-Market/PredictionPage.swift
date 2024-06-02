//
//  PredictionPage.swift
//  Stalk-Market
//
//  Created by Thanushan Pirapakaran on 2024-05-29.
//

import SwiftUI
import Foundation


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
                    HStack{
                        Text("Prediction")
                            .font(.custom("AmericanTypewriter", size: 40))
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .padding()
                    }
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
    var body: some View{
        HStack{
            
        }
        .frame(width:UIScreen.main.bounds.width*5/6)
        .background()
        .opacity(0.8)
        .cornerRadius(20.0)
        .scenePadding(.top)
    }
}
struct TickerInfoBox: View {
    var ticker:String
    @State var cost:String = "0"
    @State var currency:String = "USD"
    @State var name:String = "Name"
    var body: some View{
        HStack{
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
        }
        .frame(width:UIScreen.main.bounds.width*5/6)
        .background()
        .opacity(0.8)
        .cornerRadius(20.0)
        .scenePadding(.top)
        .onAppear{getStockInfo()}
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
