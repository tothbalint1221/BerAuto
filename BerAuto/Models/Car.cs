using System;
using System.Collections.Generic;

namespace BerAuto.Models;

public partial class Car
{
    public enum CarCategory
    {
        Economy = 0,
        SUV = 1,
        Luxury = 2
    }

    public int Id { get; set; }

    public string Brand { get; set; } = null!;

    public string Model { get; set; } = null!;

    public CarCategory Category { get; set; } 

    public decimal DailyPrice { get; set; }

    public int Mileage { get; set; }

    public bool IsAvailable { get; set; }

    public virtual ICollection<Rental> Rentals { get; set; } = new List<Rental>();
}
