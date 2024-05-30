//
//  PredictionPage.swift
//  Stalk-Market
//
//  Created by Thanushan Pirapakaran on 2024-05-29.
//

import SwiftUI

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
                }
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Gradient(colors: [
                Color(UIColor(named: "lightPurple")!), Color(UIColor(named: "darkPurple")!), Color(UIColor(named: "darkPurple")!)]).opacity(0.6))
        }
    }
}

#Preview {
    PredictionPage(ticker: "Result")
}
