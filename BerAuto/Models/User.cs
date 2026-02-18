using System;
using System.Collections.Generic;

namespace BerAuto.Models;

public partial class User
{
    public enum UserRole
    {
        User = 0,
        Clerk = 1,
        Admin = 2,

    }

    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Email { get; set; }

    public string? PasswordHash { get; set; }

    public string? Address { get; set; }

    public string? PhoneNumber { get; set; }

    public UserRole Role { get; set; } 

    public bool IsRegistered { get; set; }

    public virtual ICollection<Rental> Rentals { get; set; } = new List<Rental>();
}
